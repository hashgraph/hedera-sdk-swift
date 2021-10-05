import HederaProtoServices

public final class AccountBalance {
    var hbar: Hbar = Hbar(0)
    var tokens: [TokenId: UInt64] = [:]
    var tokenDecimals: [TokenId: UInt32] = [:]

    init() {
    }
}

extension AccountBalance: ProtobufConvertible {
    public convenience init?(_ proto: Proto_CryptoGetAccountBalanceResponse) {
        self.init()

        hbar = Hbar(proto.balance)
        tokens = Dictionary(uniqueKeysWithValues: proto.tokenBalances.map { (TokenId($0.tokenID), $0.balance) })
        tokenDecimals = Dictionary(uniqueKeysWithValues: proto.tokenBalances.map { (TokenId($0.tokenID), $0.decimals) })
    }

    public func toProtobuf() -> Proto_CryptoGetAccountBalanceResponse {
        var proto = Proto_CryptoGetAccountBalanceResponse()
        var tokenBalances: [TokenId: (UInt64, UInt32)] = [:]

        for (token, balance) in tokens {
            tokenBalances[token] = (balance, 0)
        }

        for (token, decimal) in tokenDecimals {
            if let (balance, _) = tokenBalances[token] {
                tokenBalances[token] = (balance, decimal)
            }
        }

        proto.balance = hbar.toProtobuf()
        proto.tokenBalances = tokenBalances.map{
            var tokenBalance = Proto_TokenBalance()
            tokenBalance.tokenID = $0.key.toProtobuf()
            tokenBalance.balance = $0.value.0
            tokenBalance.decimals = $0.value.1
            return tokenBalance
        }

        return proto
    }
}

extension AccountBalance: CustomStringConvertible {
    public var description: String {
        "hbars: \(hbar)\ntokens: \(tokens.description)\ntokenDecimals: \(tokenDecimals.description)"
    }

    public var debugDescription: String {
        description
    }
}