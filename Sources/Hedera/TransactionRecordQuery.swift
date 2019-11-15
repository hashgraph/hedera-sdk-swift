public final class TransactionRecordQuery: QueryBuilder<TransactionRecord> {
    public override init(client: Client) {
        super.init(client: client)

        body.transactionGetRecord = Proto_TransactionGetRecordQuery()
    }

    public func setTransaction(_ id: TransactionId) -> Self {
        body.transactionGetRecord.transactionID = id.toProto()

        return self
    }

    override func shouldRetry(_ precheckCode: Proto_ResponseCodeEnum) -> Bool {
        precheckCode == .busy || precheckCode == .unknown || precheckCode == .ok
    }

    override func mapResponse(_ response: Proto_Response) -> Result<TransactionRecord, HederaError> {
        guard case .transactionGetRecord(let response) = response.response else {
            return .failure(HederaError(message: "query response was not of type 'transactionGetRecord'"))
        }

        return .success(TransactionRecord(response.transactionRecord))
    }
}
