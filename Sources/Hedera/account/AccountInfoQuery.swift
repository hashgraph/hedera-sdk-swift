public class AccountInfoQuery: QueryBuilder<AccountInfo> {
    public override init() {
        super.init()

        body.cryptoGetInfo = Proto_CryptoGetInfoQuery()
    }

    public func setAccountId(_ id: AccountId) -> Self {
        body.cryptoGetInfo.accountID = id.toProto()

        return self
    }

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.cryptoGetInfo.header)
    }

    override func mapResponse(_ response: Proto_Response) -> AccountInfo {
        guard case .cryptoGetInfo(let response) = response.response else {
            fatalError("unreachable: response is not cryptoGetInfo")
        }

        return AccountInfo(response.accountInfo)
    }
}
