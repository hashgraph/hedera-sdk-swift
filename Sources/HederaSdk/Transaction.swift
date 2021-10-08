import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices

//import HederaProtoSdk

extension TimeInterval: ProtobufConvertible {
  public init?(_ proto: Proto_Duration) {
    self.init(proto.seconds)
  }

  public func toProtobuf() -> Proto_Duration {
    var proto = Proto_Duration()
    proto.seconds = Int64(self)
    return proto
  }
}

extension PublicKey {
  func toSignaturePairProtobuf(_ signature: [UInt8]) -> Proto_SignaturePair {
    var proto = Proto_SignaturePair()
    proto.pubKeyPrefix = Data(bytes)
    proto.ed25519 = Data(signature)
    return proto
  }
}

class Transaction: Executable<TransactionResponse, Proto_Transaction, Proto_TransactionResponse> {
  var outerTransactions: [Proto_Transaction?] = []
  var innerSignedTransactions: [Proto_SignedTransaction] = []

  var transactionIds: [TransactionId] = []
  var publicKeys: [PublicKey] = []
  var signers: [((_ bytes: [UInt8]) -> [UInt8])?] = []

  var defaultMaxTransactionFee = Hbar(2)
  var nextTransactionIndex: UInt8 = 0

  var transactionValidDuration: TimeInterval = 120
  var maxTransactionFee: Hbar?
  var memo: String?

  func requireNotFrozen() throws {
    if isFrozen() {
      throw "transaction is immutable; it has at least one signature or has been explicitly frozen"
    }
  }

  public func getTransactionValidDuration() -> TimeInterval {
    transactionValidDuration
  }

  @discardableResult
  public func setTransactionValidDuration(_ transactionValidDuration: TimeInterval) -> Self {
    self.transactionValidDuration = transactionValidDuration
    return self
  }

  public func getMaxTransactionFee() -> Hbar? {
    maxTransactionFee
  }

  @discardableResult
  public func setMaxTransactionFee(_ maxTransactionFee: Hbar) -> Self {
    self.maxTransactionFee = maxTransactionFee
    return self
  }

  public func getMemo() -> String? {
    memo
  }

  @discardableResult
  public func setMemo(_ memo: String) -> Self {
    self.memo = memo
    return self
  }

  @discardableResult
  public override func setNodeAccountIds(_ nodeAccountIds: [AccountId]) throws -> Self {
    try requireNotFrozen()
    return try super.setNodeAccountIds(nodeAccountIds)
  }

  @discardableResult
  public func setTransactionId(_ transactionId: TransactionId) -> Self {
    transactionIds.insert(transactionId, at: 0)
    return self
  }

  //  public func toBytes() -> [UInt8] {
  //    if (!isFrozen()) {
  //      let _ = try freeze()
  //    }
  //
  //    try buildAllTransactions()
  //
  //    var proto = Proto_TransactionList()
  //    proto.transactionList = outerTransactions
  //    return try proto.serializedData()
  //  }

  @discardableResult
  public func isFrozen() -> Bool {
    innerSignedTransactions.count > 0
  }

  override func onExecuteAsync(_ client: Client) throws {
    if !isFrozen() {
      try freezeWith(client)
    }

    // TODO: Checksum validation

    if let operatorId = client.getOperatorAccountId(), let transactionId = transactionIds.first,
      operatorId == transactionId.accountId
    {
      signWithOperator(client)
    }
  }

  @discardableResult
  public func freeze() throws -> Self {
    try freezeWith(nil)
  }

  @discardableResult
  func freezeWith(_ client: Client?) throws -> Self {
    if isFrozen() {
      return self
    }

    if transactionIds.isEmpty {
      guard let operatorId = client?.getOperatorAccountId() else {
        throw "Transaction ID must be set, or a client with an operator must be provided"
      }

      transactionIds.append(TransactionId.generate(operatorId))
    }

    if nodeAccountIds.isEmpty {
      guard let client = client else {
        throw "Node account IDs must be set, or a client must be provided"
      }

      nodeAccountIds = try client.network.getNodeAccountIdsForExecute().wait()
    }

    maxTransactionFee =
      maxTransactionFee ?? client?.getDefaultMaxTransactionFee() ?? defaultMaxTransactionFee

    var transactionBody = Proto_TransactionBody()
    transactionBody.transactionFee = maxTransactionFee!.toProtobuf()
    transactionBody.transactionValidDuration = transactionValidDuration.toProtobuf()
    transactionBody.memo = memo ?? ""

    onFreeze(&transactionBody)

    outerTransactions = [Proto_Transaction?](repeating: nil, count: nodeAccountIds.count)
    innerSignedTransactions = try nodeAccountIds.map {
      transactionBody.nodeAccountID = $0.toProtobuf()

      var signedTransaction = Proto_SignedTransaction()
      signedTransaction.bodyBytes = try transactionBody.serializedData()
      return signedTransaction
    }

    return self
  }

  func onFreeze(_ transactionBody: inout Proto_TransactionBody) {
    fatalError("not implemented")
  }

  @discardableResult
  public func sign(_ privateKey: PrivateKey) -> Self {
    signWith(privateKey.publicKey, privateKey.sign)
  }

  @discardableResult
  public func signWithOperator(_ client: Client) -> Self {
    client.`operator`.map { signWith($0.publicKey, $0.transactionSigner) } ?? self
  }

  @discardableResult
  public func signWith(_ publicKey: PublicKey, _ signer: @escaping (_ bytes: [UInt8]) -> [UInt8])
    -> Self
  {
    if publicKeys.contains(where: { $0.bytes == publicKey.bytes }) {
      return self
    }

    publicKeys.append(publicKey)
    signers.append(signer)

    return self
  }

  override func makeRequest() throws -> Proto_Transaction {
    let index = nextNodeIndex + UInt(Int(nextTransactionIndex) * nodeAccountIds.count)
    return try buildTransaction(Int(index))
  }

  func buildAllTransactions() throws {
    let _ = try (0..<innerSignedTransactions.count).map { try buildTransaction($0) }
  }

  func buildTransaction(_ index: Int) throws -> Proto_Transaction {
    if let transaction = outerTransactions[index], !transaction.signedTransactionBytes.isEmpty {
      return transaction
    }

    outerTransactions[index] = Proto_Transaction()
    outerTransactions[index]!.signedTransactionBytes = try signTransaction(index).serializedData()
    return outerTransactions[index]!
  }

  func signTransaction(_ index: Int) -> Proto_SignedTransaction {
    for (publicKey, signer) in zip(publicKeys, signers) {
      guard let signer = signer else {
        continue
      }

      if !innerSignedTransactions[index].sigMap.sigPair.filter({
        (sigPair: Proto_SignaturePair) -> Bool in
        sigPair.pubKeyPrefix == Data(publicKey.bytes)
      }).isEmpty {
        continue
      }

      let signature = signer(innerSignedTransactions[index].bodyBytes.bytes)
      innerSignedTransactions[index].sigMap.sigPair.append(
        publicKey.toSignaturePairProtobuf(signature))
    }

    return innerSignedTransactions[index]
  }

  //  override func mapResponse(_ request: Proto_Transaction, _ response: Proto_TransactionResponse, _ index: Int) -> TransactionResponse {
  //    let transactionId = transactionIds[Int(nextTransactionIndex) * nodes.count + index]
  //    var hash = hash(request.signedTransactionBytes.bytes)
  //
  //    nextTransactionIndex = UInt8(Int(nextTransactionIndex + 1) % transactionIds.count)
  //
  //    return TransactionResponse(transactionId, nodeAccountIds[index], hash, nil)
  //
  //  }

  override func shouldRetry(_ response: Proto_TransactionResponse) -> ExecutionState {
    super.shouldRetry(response.nodeTransactionPrecheckCode)
  }
}
