public class TransactionReceiptQuery: QueryBuilder<TransactionReceipt> {
    override var needsPayment: Bool { false }

    @discardableResult
    public func setTransactionId(_ id: TransactionId) -> Self {
        body.transactionGetReceipt.transactionID = id.toProto()
        return self
    }

    override func mapResponse(_ response: Proto_Response) -> Result<TransactionReceipt, HederaError> {
        guard case .transactionGetReceipt(let response) = response.response else {
            return .failure(HederaError(message: "query response is not of type transaction receipt"))
        }

        return .success(TransactionReceipt(response.receipt))
    }
}
