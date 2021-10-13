import Foundation
import HederaProtoServices

public final class PrecheckStatusError: Error {
  public let status: Proto_ResponseCodeEnum
  public let transactionId: TransactionId

  init(status: Proto_ResponseCodeEnum, transactionId: TransactionId) {
    self.status = status
    self.transactionId = transactionId
  }
}

extension PrecheckStatusError: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    """
    status: \(status),
    transactionId: \(transactionId)
    """
  }
  public var debugDescription: String {
    description
  }
}
