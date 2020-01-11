public final class TransactionRecordQuery: QueryBuilder<TransactionRecord> {
    public override init() {
        super.init()

        body.transactionGetRecord = Proto_TransactionGetRecordQuery()
    }

    public func setTransactionId(_ id: TransactionId) -> Self {
        body.transactionGetRecord.transactionID = id.toProto()

        return self
    }

    override func shouldRetry(_ precheckCode: Proto_ResponseCodeEnum) -> Bool {
        precheckCode == .busy || precheckCode == .unknown || precheckCode == .ok
    }

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.transactionGetRecord.header)
    }

    override func mapResponse(_ response: Proto_Response) -> TransactionRecord {
        guard case .transactionGetRecord(let response) = response.response else {
            fatalError("unreachable: response is not transactionGetRecord")
        }

        return TransactionRecord(response.transactionRecord)
    }
}
