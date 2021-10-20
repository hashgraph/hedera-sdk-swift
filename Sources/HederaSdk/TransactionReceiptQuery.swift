import Foundation
import GRPC
import HederaProtoServices
import NIO

class TransactionReceiptQuery: Query<TransactionReceipt> {
  var transactionId: TransactionId?

  public func getTransactionId() -> TransactionId? {
    transactionId
  }

  public func setTransactionId(_ transactionId: TransactionId) -> Self {
    self.transactionId = transactionId
    return self
  }

  override func isPaymentRequired() -> Bool {
    false
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Query, CallOptions?) ->
    UnaryCall<
      Proto_Query, Proto_Response
    >
  {
    nodes[circular: index].getCrypto().getTransactionReceipts
  }

  override func makeRequest(_ index: Int, save: Bool = true) -> Proto_Query {
    if let query = requests[index] {
      return query
    }

    var proto = Proto_Query()

    if let transactionId = transactionId {
      proto.transactionGetReceipt.transactionID = transactionId.toProtobuf()
    }

    if save {
      requests[index] = proto
    }

    return proto
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.transactionGetReceipt.header
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> TransactionReceipt {
    TransactionReceipt(response.transactionGetReceipt.receipt)!
  }

  override func mapStatusError(_ response: Proto_Response) -> Error {
    if case .error = shouldRetry(mapResponseHeader(response).nodeTransactionPrecheckCode) {
      return PrecheckStatusError(
        status: mapResponseHeader(response).nodeTransactionPrecheckCode,
        transactionId: transactionIds.first!)
    }

    return PrecheckStatusError(
      status: response.transactionGetReceipt.receipt.status, transactionId: transactionIds.first!)
  }

  override func shouldRetry(_ response: Proto_Response) -> ExecutionState {
    if case .retry = shouldRetry(mapResponseHeader(response).nodeTransactionPrecheckCode) {
      return .retry
    }

    switch response.transactionGetReceipt.receipt.status {
    case .platformNotActive, .busy, .unknown, .receiptNotFound:
      return .retry
    default:
      return .finished
    }
  }

  override func shouldRetry(_ code: Proto_ResponseCodeEnum) -> ExecutionState {
    switch code {
    case .platformNotActive, .busy, .unknown, .receiptNotFound:
      return .retry
    case .ok:
      return .finished
    default:
      return .error
    }
  }
}
