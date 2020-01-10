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

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.cryptoGetAccountRecords.header)
    }

    override func mapResponse(_ response: Proto_Response) -> [TransactionRecord] {
        guard case .cryptoGetAccountRecords(let response) = response.response else {
            fatalError("unreachable: response is not cryptoGetAccountRecords")
        }

        return response.records.map(TransactionRecord.init)
    }
}
