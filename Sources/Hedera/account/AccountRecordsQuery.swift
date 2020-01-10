public class AccountRecordsQuery: QueryBuilder<[TransactionRecord]> {
    public override init() {
        super.init()

        body.cryptoGetAccountRecords = Proto_CryptoGetAccountRecordsQuery()
    }

    @discardableResult
    public func setAccount(_ id: AccountId) -> Self {
        body.cryptoGetAccountRecords.accountID = id.toProto()
        return self
    }

    override func setHeader() {
        body.cryptoGetAccountRecords.header = header
    }

    override func mapResponse(_ response: Proto_Response) -> Result<[TransactionRecord], HederaError> {
        guard case .cryptoGetAccountRecords(let response) = response.response else {
            return .failure(HederaError.message("Query response was not of type crypto account records"))
        }

        return .success(response.records.map(TransactionRecord.init))
    }
}
