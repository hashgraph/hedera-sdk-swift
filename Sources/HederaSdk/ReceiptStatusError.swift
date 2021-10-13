import Foundation

public final class ReceiptStatusError: Error {
  public let transactionId: TransactionId
  public let receipt: TransactionReceipt

  init(transactionId: TransactionId, receipt: TransactionReceipt) {
    self.transactionId = transactionId
    self.receipt = receipt
  }
}
