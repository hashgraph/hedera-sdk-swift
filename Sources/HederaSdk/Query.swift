import GRPC
import HederaProtoServices
import NIO

public class Query<O>: Executable<O, Proto_Query, Proto_Response> {
  var maxQueryPayment: Hbar?
  var queryPayment: Hbar?

  @discardableResult
  public func setMaxQueryPayment(_ maxQueryPayment: Hbar) -> Self {
    self.maxQueryPayment = maxQueryPayment
    return self
  }

  @discardableResult
  public func setQueryPayment(_ queryPayment: Hbar) -> Self {
    self.queryPayment = queryPayment
    return self
  }

  func isPaymentRequired() -> Bool {
    true
  }

  func getCostAsync(_ client: Client) -> EventLoopFuture<Hbar> {
    try! CostQuery(self).setNodeAccountIds(nodeAccountIds).executeAsync(client)
  }

  override func onExecuteAsync(_ client: Client) -> EventLoopFuture<Client> {
    if !isPaymentRequired() || queryPayment != nil {
      return client.eventLoopGroup.next().makeSucceededFuture(client)
    }

    return getCostAsync(client)
      .flatMap {
        if self.queryPayment != nil {
          return client.eventLoopGroup.next().makeSucceededFuture(client)
        }

        if let maxQueryPayment = self.maxQueryPayment, $0 > maxQueryPayment {
          return client.eventLoopGroup.next().makeFailedFuture(
            MaxQueryPaymentExceededError(query: self, cost: $0, maxCost: self.maxQueryPayment!))
        }

        self.queryPayment = $0

        return client.eventLoopGroup.next().makeSucceededFuture(client)
      }
  }

  override func makeRequest(_ index: Int, save: Bool? = true) throws -> Proto_Query {
    if let query = requests[index] {
      return query
    }

    var proto = Proto_Query()

    onMakeRequest(&proto)

    if isPaymentRequired() {
      var header = Proto_QueryHeader()
      let transaction = try TransferTransaction()
        .setTransactionId(transactionIds.first!)
        .setNodeAccountIds([nodeAccountIds[circular: index]])
        .addHbarTransfer(transactionIds.first!.accountId, -queryPayment!)
        .addHbarTransfer(nodes[circular: index].accountId, queryPayment!)
        .freeze()
        .signWithOperator(`operator`)

      header.payment = try transaction.makeRequest(0, save: false)
      onFreeze(&proto, header)
    }

    if save ?? false {
      requests[index] = proto
    }

    return proto
  }

  func onMakeRequest(_ proto: inout Proto_Query) {
    fatalError("not implemented")
  }

  func onFreeze(_ query: inout Proto_Query, _ header: Proto_QueryHeader) {
    fatalError("not implemented")
  }

  func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    fatalError("not implemented")
  }

  override func shouldRetry(_ response: Proto_Response) -> ExecutionState {
    super.shouldRetry(mapResponseHeader(response).nodeTransactionPrecheckCode)
  }
}

final class CostQuery<O>: Query<Hbar> {
  let query: Query<O>

  init(_ query: Query<O>) {
    self.query = query
  }

  override func isPaymentRequired() -> Bool {
    false
  }

  override func executeAsync(_ index: Int, save: Bool? = true) throws -> UnaryCall<
    Proto_Query, Proto_Response
  > {
    try query.executeAsync(index, save: false)
  }

  override func makeRequest(_ index: Int, save: Bool? = true) throws -> Proto_Query {
    var proto = try query.makeRequest(index, save: false)
    var header = Proto_QueryHeader()
    header.responseType = .costAnswer

    query.onFreeze(&proto, header)

    if save ?? false {
      requests[index] = proto
    }

    return proto
  }

  override func onFreeze(_ proto: inout Proto_Query, _ header: Proto_QueryHeader) {
    query.onFreeze(&proto, header)
  }

  override func onMakeRequest(_ proto: inout Proto_Query) {
    query.onMakeRequest(&proto)
  }

  override func mapStatusError(_ response: Proto_Response) -> Error {
    PrecheckStatusError(
      status: mapResponseHeader(response).nodeTransactionPrecheckCode,
      transactionId: transactionIds.first!)
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    query.mapResponseHeader(response)
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> Hbar {
    Hbar(query.mapResponseHeader(response).cost)
  }
}
