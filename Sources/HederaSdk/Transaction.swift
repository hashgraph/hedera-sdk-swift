import CryptoSwift
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
  var innerSignedTransactions: [Proto_SignedTransaction] = []

  var transactionValidDuration: TimeInterval = 120
  var defaultMaxTransactionFee = Hbar(hbars: 2)
  var maxTransactionFee: Hbar?
  var memo: String?

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

  public func getTransactionHash() throws -> [UInt8] {
    try requireFrozen()
    return hash(try makeRequest(index).signedTransactionBytes.bytes)
  }

  public func getTransactionHashPerNode() throws -> [AccountId: [UInt8]] {
    try requireFrozen()
    try makeAllRequests()
    return Dictionary(
      uniqueKeysWithValues: requests.enumerated().map {
        (nodeAccountIds[circular: $0.offset], hash($0.element!.signedTransactionBytes.bytes))
      })
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
  override func freezeWith(_ client: Client?) throws -> Self {
    try super.freezeWith(client)

    maxTransactionFee =
      maxTransactionFee ?? client?.getDefaultMaxTransactionFee() ?? defaultMaxTransactionFee

    innerSignedTransactions = try (0..<nodeAccountIds.count).map { try makeSignedRequest($0) }

    return self
  }

  func onFreeze(_ transactionBody: inout Proto_TransactionBody) {
    fatalError("not implemented")
  }

  func makeTransactionBody(_ index: Int) -> Proto_TransactionBody {
    var transactionBody = Proto_TransactionBody()
    transactionBody.transactionFee = maxTransactionFee!.toProtobuf()
    transactionBody.transactionValidDuration = transactionValidDuration.toProtobuf()
    transactionBody.memo = memo ?? ""
    transactionBody.nodeAccountID = nodeAccountIds[Int(index) % nodeAccountIds.count].toProtobuf()

    onFreeze(&transactionBody)

    return transactionBody
  }

  func makeSignedRequest(_ index: Int) throws -> Proto_SignedTransaction {
    innerSignedTransactions[index] = Proto_SignedTransaction()
    innerSignedTransactions[index].bodyBytes = try makeTransactionBody(index).serializedData()
    return innerSignedTransactions[index]
  }

  override func makeAllRequests() throws {
    let _ = try (0..<innerSignedTransactions.count).map { try makeRequest($0) }
  }

  override func makeRequest(_ index: Int) throws -> Proto_Transaction {
    if let transaction = requests[index], !transaction.signedTransactionBytes.isEmpty {
      return transaction
    }

    requests[index] = Proto_Transaction()
    requests[index]!.signedTransactionBytes = try signTransaction(index).serializedData()
    return requests[index]!
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

  override func mapResponse(_ index: Int, _ response: Proto_TransactionResponse)
    -> TransactionResponse
  {
    let transactionId = transactionIds[index / nodeAccountIds.count]
    let hash = hash(requests[index]!.signedTransactionBytes.bytes)

    return TransactionResponse(transactionId, nodeAccountIds[index], hash, nil)

  }

  override func shouldRetry(_ response: Proto_TransactionResponse) -> ExecutionState {
    super.shouldRetry(response.nodeTransactionPrecheckCode)
  }
}

func hash(_ bytes: [UInt8]) -> [UInt8] {
  SHA3(variant: .sha384).calculate(for: bytes)
}
