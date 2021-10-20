import HederaProtoServices

public final class TokenNftTransfer {
  public let senderAccountId: AccountId?
  public let receiverAccountId: AccountId?
  public let serialNumber: Int64

  init(_ senderAccountId: AccountId?, _ receiverAccountId: AccountId?, _ serialNumber: Int64) {
    self.senderAccountId = senderAccountId
    self.receiverAccountId = receiverAccountId
    self.serialNumber = serialNumber
  }
}

extension TokenNftTransfer: ProtobufConvertible {
  convenience init?(_ proto: Proto_NftTransfer) {
    self.init(
      proto.hasSenderAccountID ? AccountId(proto.senderAccountID) : nil,
      proto.hasReceiverAccountID ? AccountId(proto.receiverAccountID) : nil,
      proto.serialNumber
    )
  }

  func toProtobuf() -> Proto_NftTransfer {
    var proto = Proto_NftTransfer()
    proto.serialNumber = serialNumber

    if let senderAccountId = senderAccountId {
      proto.senderAccountID = senderAccountId.toProtobuf()
    }

    if let receiverAccountID = receiverAccountId {
      proto.receiverAccountID = receiverAccountID.toProtobuf()
    }

    return proto
  }
}
