import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

enum ExecutionState {
  case retry
  case finished
  case error
}

extension Array {
  subscript(circular index: Int) -> Element {
    self[Int(index) % count]
  }
}

public class Executable<O, RequestT, ResponseT> {
  var requests: [RequestT?] = []
  var nodeAccountIds: [AccountId] = []
  var transactionIds: [TransactionId] = []
  var publicKeys: [PublicKey] = []
  var signers: [((_ bytes: [UInt8]) -> [UInt8])?] = []
  var nodes: [Node] = []

  var maxAttempts: UInt?
  var maxBackoff: TimeInterval?
  var minBackoff: TimeInterval?
  var nextNodeIndex: Int = 0
  var nextTransactionIdIndex: Int = 0

  var `operator`: Operator?

  var index: Int {
    nextNodeIndex + nextTransactionIdIndex * nodeAccountIds.count
  }

  public init() {
  }

  public func getMinBackoff() -> TimeInterval? {
    minBackoff
  }

  @discardableResult
  public func setMinBackoff(_ minBackoff: TimeInterval) -> Self {
    self.minBackoff = minBackoff
    return self
  }

  public func getMaxBackoff() -> TimeInterval? {
    maxBackoff
  }

  @discardableResult
  public func setMaxBackoff(_ maxBackoff: TimeInterval) -> Self {
    self.maxBackoff = maxBackoff
    return self
  }

  public func getMaxAttempts() -> UInt? {
    maxAttempts
  }

  @discardableResult
  public func setMaxAttempts(_ maxAttempts: UInt) -> Self {
    self.maxAttempts = maxAttempts
    return self
  }

  public func getNodeAccountIds() -> [AccountId] {
    nodeAccountIds
  }

  @discardableResult
  public func setNodeAccountIds(_ nodeAccountIds: [AccountId]) throws -> Self {
    self.nodeAccountIds = nodeAccountIds
    return self
  }

  @discardableResult
  func setNodes(_ nodes: [Node]) -> Self {
    self.nodes = nodes
    return self
  }

  func onExecuteAsync(_ client: Client) -> EventLoopFuture<Client> {
    if !isFrozen() {
      do {
        try freezeWith(client)
      } catch {
        return client.eventLoopGroup.next().makeFailedFuture(error)
      }
    }

    // TODO: Checksum validation

    if let operatorId = client.getOperatorAccountId(), let transactionId = transactionIds.first,
      operatorId == transactionId.accountId
    {
      signWithOperator(client)
    }

    return client.eventLoopGroup.next().makeSucceededFuture(client)
  }

  func makeRequest() throws -> RequestT {
    fatalError("not implemented")
  }

  func shouldRetry(_ response: ResponseT) -> ExecutionState {
    fatalError("not implemented")
  }

  func shouldRetry(_ code: Proto_ResponseCodeEnum) -> ExecutionState {
    switch code {
    case .platformNotActive, .busy, .unknown:
      return .retry
    case .ok:
      return .finished
    default:
      return .error
    }
  }

  func shouldRetryExceptionally(_ status: GRPCStatus) -> Bool {
    switch status.code {
    case .unauthenticated, .resourceExhausted,
      .internalError
    where status.description.range(
      of: ".*\\brst[0-9a-zA-Z]stream\\b.*", options: .regularExpression) != nil:
      return true
    default:
      return false
    }
  }

  func requireFrozen() throws {
    if isFrozen() {
      throw "request must be frozen"
    }
  }

  func requireNotFrozen() throws {
    if isFrozen() {
      throw "request is immutable; it has at least one signature or has been explicitly frozen"
    }
  }

  public func isFrozen() -> Bool {
    !requests.isEmpty
  }

  func isTransactionIdRequired() -> Bool {
    true
  }

  @discardableResult
  public func freeze() throws -> Self {
    try freezeWith(nil)
  }

  @discardableResult
  public func freezeWith(_ client: Client?) throws -> Self {
    if isFrozen() {
      return self
    }

    `operator` = client?.operator

    if transactionIds.isEmpty && isTransactionIdRequired() {
      guard let operatorId = client?.getOperatorAccountId() else {
        throw "Transaction ID must be set, or a client with an operator must be provided"
      }

      transactionIds.append(TransactionId.generate(operatorId))
    } else {
      transactionIds.append(TransactionId(AccountId(0), Date(timeIntervalSince1970: 0)))
    }

    if nodeAccountIds.isEmpty {
      guard let client = client else {
        throw "Node account IDs must be set, or a client must be provided"
      }

      nodeAccountIds = try client.network.getNodeAccountIdsForExecute().wait()
    }

    requests = [RequestT?](repeating: nil, count: nodeAccountIds.count)

    try onFreezeWith(client)

    return self
  }

  func onFreezeWith(_ client: Client?) throws {
  }

  @discardableResult
  public func sign(_ privateKey: PrivateKey) -> Self {
    signWith(privateKey.publicKey, privateKey.sign)
  }

  @discardableResult
  public func signWithOperator(_ client: Client) -> Self {
    signWithOperator(client.operator)
  }

  @discardableResult
  func signWithOperator(_ `operator`: Operator?) -> Self {
    `operator`.map { signWith($0.publicKey, $0.transactionSigner) } ?? self
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

  func makeAllRequests() throws {
    try requests = (0..<nodeAccountIds.count).map { try makeRequest($0) }
  }

  func makeRequest(_ index: Int, save: Bool = true) throws -> RequestT {
    fatalError("not implemented")
  }

  func mapResponse(_ index: Int, _ response: ResponseT) -> O {
    fatalError("not implemented")
  }

  func mapStatusError(_ response: ResponseT) -> Error {
    fatalError("not implemented")
  }

  func getMethodDescriptor(_ index: Int) -> (_ request: RequestT, CallOptions?) -> UnaryCall<
    RequestT, ResponseT
  > {
    fatalError("not implemented")
  }

  func executeAsync(_ attempt: UInt, _ eventLoop: EventLoop) -> EventLoopFuture<O> {
    if attempt >= maxAttempts! {
      return eventLoop.makeFailedFuture(MaxAttemptsExceededError(maxAttempts!))
    }

    let node = nodes[circular: nextNodeIndex]

    if !node.isHealthy() {
      return eventLoop.scheduleTask(
        in: TimeAmount.milliseconds(Int64(node.getRemainingTimeForBackoff()))
      ) { () }
      .futureResult.flatMap { _ in self.executeAsync(attempt, eventLoop) }
    }

    do {
      let call = getMethodDescriptor(index)(try makeRequest(index), nil)
      let responseFuture = call.response

      return call.status
        .flatMap { status in responseFuture.map { ($0, status) } }
        .flatMap { (response, status) in
          if self.shouldRetryExceptionally(status) {
            return self.executeAsync(attempt + 1, eventLoop)
          }

          switch self.shouldRetry(response) {
          case .retry:
            let delay = max(Double(self.minBackoff!), 250 * pow(2.0, (Double(attempt - 1))))

            return eventLoop.scheduleTask(in: TimeAmount.milliseconds(Int64(delay))) { () }
              .futureResult.flatMap { _ in self.executeAsync(attempt + 1, eventLoop) }
          case .error:
            return eventLoop.makeFailedFuture(self.mapStatusError(response))
          case .finished:
            self.nextNodeIndex = self.nextNodeIndex + 1 % self.nodeAccountIds.count
            self.nextTransactionIdIndex =
              self.nextTransactionIdIndex + 1 % self.transactionIds.count

            return eventLoop.makeSucceededFuture(self.mapResponse(self.index, response))
          }
        }
    } catch {
      return eventLoop.makeFailedFuture(error)
    }
  }

  public func executeAsync(_ client: Client) -> EventLoopFuture<O> {
    do {
      try freezeWith(client)
    } catch {
      return client.eventLoopGroup.next().makeFailedFuture(error)
    }

    maxAttempts = maxAttempts ?? client.maxAttempts
    maxBackoff = maxBackoff ?? client.maxBackoff
    minBackoff = minBackoff ?? client.minBackoff

    return onExecuteAsync(client).flatMap {
      $0.network.getNodeAccountIdsForExecute().map {
        self.setNodes($0.compactMap { client.network.network[$0] })
      }.flatMap { self.executeAsync(1, client.eventLoopGroup.next()) }
    }
  }
}
