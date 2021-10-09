import Foundation
import HederaProtoServices

public final class ExchangeRate {
  public let hbars: Hbar
  public let cents: Int32
  public let expirationTime: Date?

  public init(_ hbars: Hbar, _ cents: Int32, _ expirationTime: Date?) {
    self.hbars = hbars
    self.cents = cents
    self.expirationTime = expirationTime
  }
}

extension ExchangeRate: ProtobufConvertible {
  public convenience init?(_ proto: Proto_ExchangeRate) {
    self.init(
      Hbar(UInt64(proto.hbarEquiv)),
      proto.centEquiv,
      proto.hasExpirationTime
        ? Date(timeIntervalSince1970: Double(proto.expirationTime.seconds)) : nil)
  }

  public func toProtobuf() -> Proto_ExchangeRate {
    var proto = Proto_ExchangeRate()
    proto.hbarEquiv = Int32(hbars.toProtobuf())
    proto.centEquiv = cents

    if let expirationTime = expirationTime {
      proto.expirationTime.seconds = Int64(expirationTime.timeIntervalSince1970)
    }

    return proto
  }
}
