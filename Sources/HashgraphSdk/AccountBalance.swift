import HederaProtoServices

public final class AccountBalance {
    var hbar: Hbar = Hbar(0)
    var tokens: [TokenId: UInt64] = [:]
    var tokenDecimals: [TokenId: UInt32] = [:]

    init() {
    }

    init(_ hbar: Hbar, _ tokens: [TokenId: UInt64], _ tokenDecimals: [TokenId: UInt32]) {
        self.hbar = hbar
        self.tokens = tokens
        self.tokenDecimals = tokenDecimals
    }
}

extension AccountBalance: ProtobufConvertible {
    convenience init?(_ proto: Proto_CryptoGetAccountBalanceResponse) {
        let balance = Hbar(proto.balance)
        let tokens = Dictionary(uniqueKeysWithValues: proto.tokenBalances.map { (TokenId($0.tokenID), $0.balance) })
        let tokenDecimals = Dictionary(uniqueKeysWithValues: proto.tokenBalances.map { (TokenId($0.tokenID), $0.decimals) })

        self.init(balance, tokens, tokenDecimals)
    }

    func toProtobuf() -> Proto_CryptoGetAccountBalanceResponse {
        var proto = Proto_CryptoGetAccountBalanceResponse()
        proto.balance = hbar.toProtobuf()
        var tokenBalances: [TokenId: (UInt64, UInt32)] = [:]

        for (token, balance) in tokens {
            tokenBalances[token] = (balance, 0)
        }

        for (token, decimal) in tokenDecimals {
            if let (balance, _) = tokenBalances[token] {
                tokenBalances[token] = (balance, decimal)
            }
        }

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