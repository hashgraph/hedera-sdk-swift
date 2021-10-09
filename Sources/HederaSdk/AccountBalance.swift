import HederaProtoServices

public final class AccountBalance {
  public let hbars: Hbar
  public let tokens: [TokenId: UInt64]
  public let tokenDecimals: [TokenId: UInt32]

  init(_ hbars: Hbar, _ tokens: [TokenId: UInt64], _ tokenDecimals: [TokenId: UInt32]) {
    self.hbars = hbars
    self.tokens = tokens
    self.tokenDecimals = tokenDecimals
  }
}

extension AccountBalance: ProtobufConvertible {
  public convenience init?(_ proto: Proto_CryptoGetAccountBalanceResponse) {
    let hbars = Hbar(proto.balance)
    let tokens = Dictionary(
      uniqueKeysWithValues: proto.tokenBalances.map { (TokenId($0.tokenID), $0.balance) })
    let tokenDecimals = Dictionary(
      uniqueKeysWithValues: proto.tokenBalances.map { (TokenId($0.tokenID), $0.decimals) })

    self.init(hbars, tokens, tokenDecimals)
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

    proto.balance = hbars.toProtobuf()
    proto.tokenBalances = tokenBalances.map {
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
    "hbars: \(hbars)\ntokens: \(tokens.description)\ntokenDecimals: \(tokenDecimals.description)"
  }

  public var debugDescription: String {
    description
  }
}
