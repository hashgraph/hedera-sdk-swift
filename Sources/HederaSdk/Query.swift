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
    if !isPaymentRequired() {
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

  //  func makeRequest(_ index: Int, save: Bool? = true) -> Proto_Query {
  //    var from = Proto_AccountAmount()
  //    accountAmount.accountID = transactionIds.first!.accountId
  //    accountAmount.amount = queryPayment!.toProtobuf()
  //
  //    var to = Proto_AccountAmount()
  //    accountAmount.accountID = nodes[circular: index].accountId.toProtobuf()
  //    accountAmount.amount = -queryPayment!.toProtobuf()
  //
  //    var accountAmounts = [from, to]
  //
  //    var transfers = Proto_TransferList()
  //    transfers.accountAmounts = accountAmounts
  //
  //    var transactionBody = Proto_CryptoTransferTransactionBody()
  //    proto.transfers = transfers
  //
  //    var bodyBytes = try transactionBody.serializedData()
  //
  //  }

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
    requests[index] = try query.makeRequest(index, save: false)
    return requests[index]!
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
