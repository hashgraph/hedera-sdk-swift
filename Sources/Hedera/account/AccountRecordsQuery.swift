public class AccountRecordsQuery: QueryBuilder<[TransactionRecord]> {
    public override init(client: Client) {
        super.init(client: client)

        body.cryptoGetAccountRecords = Proto_CryptoGetAccountRecordsQuery()
    }

    @discardableResult
    public func setAccount(_ id: AccountId) -> Self {
        body.cryptoGetAccountRecords.accountID = id.toProto()
        return self
    }

    override func mapResponse(_ response: Proto_Response) throws -> [TransactionRecord] {
        guard case .cryptoGetAccountRecords(let response) = response.response else {
            throw HederaError(message: "Query response was not of type crypto account records")
        }

        return response.records.map(TransactionRecord.init)
    }
}
