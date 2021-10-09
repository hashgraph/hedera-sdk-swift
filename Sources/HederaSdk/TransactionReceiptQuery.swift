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

  override func executeAsync(_ index: Int) -> UnaryCall<Proto_Query, Proto_Response> {
    nodes[circular: index].getCrypto().getTransactionReceipts(makeRequest(index))
  }

  override func makeRequest(_ index: Int) -> Proto_Query {
    if let query = requests[index] {
      return query
    }

    requests[index] = Proto_Query()

    if let transactionId = transactionId {
      requests[index]!.transactionGetReceipt.transactionID = transactionId.toProtobuf()
    }

    return requests[index]!
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.transactionGetReceipt.header
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> TransactionReceipt {
    TransactionReceipt(response.transactionGetReceipt.receipt)!
  }
}
