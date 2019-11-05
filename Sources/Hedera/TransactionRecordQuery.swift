public final class TransactionRecordQuery: QueryBuilder<TransactionRecord> {
    public override init(client: Client) {
        super.init(client: client)

        body.transactionGetRecord = Proto_TransactionGetRecordQuery()
    }

    public func setTransaction(_ id: TransactionId) -> Self {
        body.transactionGetRecord.transactionID = id.toProto()

        return self
    }

    override func mapResponse(_ response: Proto_Response) throws -> TransactionRecord {
        guard case .transactionGetRecord(let response) = response.response else {
            throw HederaError(message: "query response was not of type 'transactionGetRecord'")
        }

        return TransactionRecord(response.transactionRecord)
    }
}
