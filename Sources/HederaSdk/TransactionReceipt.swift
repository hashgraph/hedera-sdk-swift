import Foundation
import HederaProtoServices

public final class TransactionReceipt {
  public let status: Proto_ResponseCodeEnum
  public let exchangeRate: ExchangeRate?
  public let accountId: AccountId?

  // TODO: Other entity IDs

  public let topicSequenceNumber: UInt64
  public let topicRunningHash: [UInt8]
  public let totalSupply: UInt64
  public let scheduledTransactionId: TransactionId?
  public let serials: [UInt64]

  init(
    _ status: Proto_ResponseCodeEnum, _ exchangeRate: ExchangeRate?, _ accountId: AccountId?,
    _ topicSequenceNumber: UInt64, _ topicRunningHash: [UInt8], _ totalSupply: UInt64,
    _ scheduledTransactionId: TransactionId?, _ serials: [UInt64]
  ) {
    self.status = status
    self.exchangeRate = exchangeRate
    self.accountId = accountId
    self.topicSequenceNumber = topicSequenceNumber
    self.topicRunningHash = topicRunningHash
    self.totalSupply = totalSupply
    self.scheduledTransactionId = scheduledTransactionId
    self.serials = serials
  }
}

extension TransactionReceipt: ProtobufConvertible {
  public convenience init?(_ proto: Proto_TransactionReceipt) {
    self.init(
      proto.status,
      proto.hasExchangeRate ? ExchangeRate(proto.exchangeRate.currentRate) : nil,
      proto.hasAccountID ? AccountId(proto.accountID) : nil, proto.topicSequenceNumber,
      proto.topicRunningHash.bytes,
      proto.newTotalSupply,
      proto.hasScheduledTransactionID ? TransactionId(proto.scheduledTransactionID) : nil,
      proto.serialNumbers.map { UInt64($0) }
    )
  }

  public func toProtobuf() -> Proto_TransactionReceipt {
    var proto = Proto_TransactionReceipt()
    proto.status = status
    proto.topicSequenceNumber = topicSequenceNumber
    proto.newTotalSupply = totalSupply
    proto.topicRunningHash = Data(topicRunningHash)
    proto.serialNumbers = serials.map { Int64($0) }

    if let exchangeRate = exchangeRate {
      proto.exchangeRate.currentRate = exchangeRate.toProtobuf()
    }

    if let accountId = accountId {
      proto.accountID = accountId.toProtobuf()
    }

    if let scheduledTransactionId = scheduledTransactionId {
      proto.scheduledTransactionID = scheduledTransactionId.toProtobuf()
    }

    return proto
  }
}

extension TransactionReceipt: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    """
    status: \(status)
    exchangeRate: \(String(describing: exchangeRate))
    accountId: \(String(describing: accountId))
    topicSequenceNumber: \(topicSequenceNumber)
    topicRunningHash: \(topicRunningHash)
    totalSupply: \(totalSupply)
    scheduledTransactionId: \(String(describing: scheduledTransactionId))
    serials: \(serials)
    """
  }

  public var debugDescription: String {
    description
  }
}
