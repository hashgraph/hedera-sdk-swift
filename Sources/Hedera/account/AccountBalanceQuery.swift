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

    override func mapResponse(_ response: Proto_Response) throws -> UInt64 {
        guard case .cryptogetAccountBalance(let response) = response.response else {
            throw HederaError(message: "Query response was not of type account balance")
        }

        return response.balance
    }
}
