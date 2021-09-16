import HederaProtoServices

public class AccountBalanceQuery  {
    var accountId: Optional<AccountId> = nil

    public init() {
    }

    @discardableResult
    public func setAccountId(_ accountId: AccountId) -> Self {
        self.accountId = accountId
        return self
    }
}

extension AccountBalanceQuery: FromResponse {
    func mapResponse(_ response: Proto_Response) -> AccountBalance {
        guard case .cryptogetAccountBalance(let response) = response.response else {
            fatalError("unreachable: response is not cryptogetAccountBalance")
        }

        return AccountBalance(response) ?? AccountBalance()
    }
}

