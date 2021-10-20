import HederaProtoServices

public final class TokenTransfer {
  public let accountId: AccountId?
  public let amount: Int64

  init(_ amount: Int64, _ accountId: AccountId?) {
    self.amount = amount
    self.accountId = accountId
  }
}

extension TokenTransfer: ProtobufConvertible {
  convenience init?(_ proto: Proto_AccountAmount) {
    self.init(
      proto.amount,
      proto.hasAccountID ? AccountId(proto.accountID) : nil
    )
  }

  func toProtobuf() -> Proto_AccountAmount {
    var proto = Proto_AccountAmount()
    proto.amount = amount

    if let accountId = accountId {
      proto.accountID = accountId.toProtobuf()
    }

    return proto
  }
}
