public class AccountBalanceQuery: QueryBuilder<UInt64> {
    public override init(node: Node) {
        super.init(node: node)

        body.cryptogetAccountBalance = Proto_CryptoGetAccountBalanceQuery()
    }

    @discardableResult
    public func setAccount(_ id: AccountId) -> Self {
        body.cryptogetAccountBalance.accountID = id.toProto()
        return self
    }

    override func mapResponse(_ response: Proto_Response) -> Result<UInt64, HederaError> {
        guard case .cryptogetAccountBalance(let response) = response.response else {
            return .failure(HederaError(message: "unreachable: query response was not of type account balance"))
        }

        return .success(response.balance)
    }
}
