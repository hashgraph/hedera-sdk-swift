public class AccountBalanceQuery: QueryBuilder<UInt64> {
    public override init(client: Client) {
        super.init(client: client)

        body.cryptogetAccountBalance = Proto_CryptoGetAccountBalanceQuery()
    }

    @discardableResult
    public func setAccount(_ id: AccountId) -> Self {
        body.cryptogetAccountBalance.accountID = id.toProto()
        return self
    }

    override func mapResponse(_ response: Proto_Response) -> Result<UInt64, HederaError> {
        guard case .cryptogetAccountBalance(let response) = response.response else {
            return .failure(HederaError(message: "Query response was not of type account balance"))
        }

        return .success(response.balance)
    }
}
