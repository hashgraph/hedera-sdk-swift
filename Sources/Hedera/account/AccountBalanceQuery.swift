public class AccountBalanceQuery: QueryBuilder<Hbar> {
    public override init() {
        super.init()

        body.cryptogetAccountBalance = Proto_CryptoGetAccountBalanceQuery()
    }

    @discardableResult
    public func setAccountId(_ id: AccountId) -> Self {
        body.cryptogetAccountBalance.accountID = id.toProto()
        return self
    }

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.cryptogetAccountBalance.header)
    }

    override func mapResponse(_ response: Proto_Response) -> Hbar {
        guard case .cryptogetAccountBalance(let response) = response.response else {
            fatalError("unreachable: response is not cryptogetAccountBalance")
        }

        return Hbar.fromTinybar(amount: Int64(response.balance))
    }
}
