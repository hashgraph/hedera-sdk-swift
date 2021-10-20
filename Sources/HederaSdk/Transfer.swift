import HederaProtoServices

public final class Transfer {
  public let accountId: AccountId?
  public let amount: Hbar

  init(_ amount: Hbar, _ accountId: AccountId?) {
    self.amount = amount
    self.accountId = accountId
  }
}

extension Transfer: ProtobufConvertible {
  convenience init?(_ proto: Proto_AccountAmount) {
    self.init(
      Hbar(proto.amount),
      proto.hasAccountID ? AccountId(proto.accountID) : nil
    )
  }

  convenience init?(_ proto: Proto_ProxyStaker) {
    self.init(
      Hbar(proto.amount),
      proto.hasAccountID ? AccountId(proto.accountID) : nil
    )
  }

  func toProtobuf() -> Proto_AccountAmount {
    var proto = Proto_AccountAmount()
    proto.amount = amount.toProtobuf()

    if let accountId = accountId {
      proto.accountID = accountId.toProtobuf()
    }

    return proto
  }
}
