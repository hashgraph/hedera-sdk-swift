public class TransactionReceiptQuery: QueryBuilder<TransactionReceipt> {
    override var needsPayment: Bool { false }

    @discardableResult
    public func setTransaction(_ id: TransactionId) -> Self {
        body.transactionGetReceipt.transactionID = id.toProto()
        return self
    }

    override func shouldRetry(_ precheckCode: Proto_ResponseCodeEnum) -> Bool {
        precheckCode == .busy || precheckCode == .unknown || precheckCode == .ok
    }

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.transactionGetReceipt.header)
    }

    override func mapResponse(_ response: Proto_Response) -> TransactionReceipt {
        guard case .transactionGetReceipt(let response) = response.response else {
            fatalError("unreachable: response is not transactionGetReceipt")
        }

        return TransactionReceipt(response.receipt)
    }
}
