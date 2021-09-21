import HederaProtoServices

public final class AccountBalanceQuery : Query<AccountBalance> {
    var accountId: Optional<AccountId> = nil

    @discardableResult
    public func setAccountId(_ accountId: AccountId) -> Self {
        self.accountId = accountId
        return self
    }
}

extension AccountBalanceQuery: ProtobufConvertible {
    public convenience init?(_ proto: Proto_Query) {
        self.init()

        setAccountId(AccountId(proto.cryptogetAccountBalance.accountID))
    }

    public func toProtobuf() -> Proto_Query {
        var proto = Proto_Query()

        if let accountId = accountId {
            proto.cryptogetAccountBalance.accountID = accountId.toProtobuf()
        }

        return proto
    }
}

extension AccountBalanceQuery: FromResponse {
    func mapResponse(_ response: Proto_Response) -> AccountBalance? {
        guard case .cryptogetAccountBalance(let response) = response.response else {
            fatalError("unreachable: response is not cryptogetAccountBalance")
        }

        return AccountBalance(response)
    }
}

