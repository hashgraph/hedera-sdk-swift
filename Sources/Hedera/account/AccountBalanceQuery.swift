public class AccountBalanceQuery: QueryBuilder<UInt64> {
    public override init() {
        super.init()

        body.cryptogetAccountBalance = Proto_CryptoGetAccountBalanceQuery()
    }

    @discardableResult
    public func setAccountId(_ id: AccountId) -> Self {
        body.cryptogetAccountBalance.accountID = id.toProto()
        return self
    }

    override func setHeader() {
        body.cryptogetAccountBalance.header = header
    }

    override func mapResponse(_ response: Proto_Response) -> Result<UInt64, HederaError> {
        guard case .cryptogetAccountBalance(let response) = response.response else {
            return .failure(HederaError.message("unreachable: query response was not of type account balance"))
        }

        return .success(response.balance)
    }
}
