import Foundation
import HederaProtoServices
import NIO

public final class TransactionId {
  let accountId: AccountId
  let validStart: Date
  var scheduled: Bool = false

  public init(_ accountId: AccountId, _ validStart: Date) {
    self.accountId = accountId
    self.validStart = validStart
  }

  public class func withValidStart(_ accountId: AccountId, _ validStart: Date) -> TransactionId {
    self.init(accountId, validStart)
  }

  public class func generate(_ accountId: AccountId) -> TransactionId {
    self.init(
      accountId, Date()
      //            .addingTimeInterval(-Double.random(in: 0..<5))
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

  public func getReceiptAsync(_ client: Client) -> EventLoopFuture<TransactionReceipt> {
    TransactionReceiptQuery()
      .setTransactionId(self)
      .executeAsync(client)
  }
}

extension Date: ProtobufConvertible {
  public init?(_ proto: Proto_Timestamp) {
    self.init(timeIntervalSince1970: Double(proto.seconds) + Double(proto.nanos) / 1_000_000_000)
  }

  public func toProtobuf() -> Proto_Timestamp {
    var proto = Proto_Timestamp()
    proto.seconds = Int64(floor(timeIntervalSince1970))
    proto.nanos = Int32(Int64(timeIntervalSince1970.truncatingRemainder(dividingBy: 1) * 1_000_000))
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
  public var description: String {
    "\(accountId)@\(validStart.timeIntervalSince1970)"
      + (scheduled ? "?scheduled" : "")
  }

  public var debugDescription: String {
    description
  }
}
