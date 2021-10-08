import HederaProtoServices

public class Query<O: ProtobufConvertible>: Executable<O, Proto_Query, Proto_Response> {
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

  override func onExecuteAsync(_ client: Client) {
    if !isPaymentRequired() {
      return
    }
  }

  func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    fatalError("not implemented")
  }

  override func shouldRetry(_ response: Proto_Response) -> ExecutionState {
    super.shouldRetry(mapResponseHeader(response).nodeTransactionPrecheckCode)
  }
}
