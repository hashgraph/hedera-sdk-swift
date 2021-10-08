import Foundation
import HederaProtoServices

final class TransactionId {
  let accountId: AccountId
  let validStart: Date
  var scheduled: Bool = false

  public init(_ accountId: AccountId, _ validStart: Date) {
    self.accountId = accountId
    self.validStart = validStart
  }

  public static func withValidStart(_ accountId: AccountId, _ validStart: Date) -> TransactionId {
    self.init(accountId, validStart)
  }

  public static func generate(_ accountId: AccountId) -> TransactionId {
    self.init(
      accountId, Date().addingTimeInterval(Double.random(in: 0..<1) * 5_000_000_000 + 8_000_000_000)
    )
  }

  public func getAccountId() -> AccountId {
    accountId
  }

  public func getValidStart() -> Date {
    validStart
  }

  public func getScheduled() -> Bool {
    scheduled
  }

  @discardableResult
  public func setScheduled(_ scheduled: Bool) -> Self {
    self.scheduled = scheduled
    return self
  }
}

extension Date: ProtobufConvertible {
  public init?(_ proto: Proto_Timestamp) {
    self.init(timeIntervalSince1970: Double(proto.seconds) + Double(proto.nanos) / 1_000_000_000)
  }

  public func toProtobuf() -> Proto_Timestamp {
    var proto = Proto_Timestamp()
    proto.seconds = Int64(timeIntervalSince1970)
    proto.nanos = Int32(Int64(timeIntervalSince1970 * 1_000_000_000) % 1_000_000_000)
    return proto
  }
}

extension TransactionId: ProtobufConvertible {
  public convenience init?(_ proto: Proto_TransactionID) {
    guard let accountId = proto.hasAccountID ? AccountId(proto.accountID) : nil,
      let validStart = proto.hasTransactionValidStart ? Date(proto.transactionValidStart) : nil
    else {
      return nil
    }

    self.init(accountId, validStart)
    setScheduled(proto.scheduled)
  }

  public func toProtobuf() -> Proto_TransactionID {
    var proto = Proto_TransactionID()
    proto.accountID = accountId.toProtobuf()
    proto.transactionValidStart = validStart.toProtobuf()
    proto.scheduled = scheduled
    return proto
  }
}

extension TransactionId: Equatable {
  public static func == (lhs: TransactionId, rhs: TransactionId) -> Bool {
    lhs.accountId == rhs.accountId && lhs.validStart == rhs.validStart
      && lhs.scheduled == rhs.scheduled
  }
}

extension TransactionId: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(accountId)
    hasher.combine(validStart)
    hasher.combine(scheduled)
  }
}

extension TransactionId: CustomStringConvertible, CustomDebugStringConvertible {
  var description: String {
    "\(accountId)@\(Int64(validStart.timeIntervalSince1970)).\(Int32(Int64(validStart.timeIntervalSince1970 * 1_000_000_000) % 1_000_000_000))"
      + (scheduled ? "?scheduled" : "")
  }

  public var debugDescription: String {
    description
  }
}