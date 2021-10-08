import Foundation

class TransactionResponse {
  let transactionId: TransactionId
  let nodeAccountId: AccountId
  let transactionHash: [UInt8]
  let scheduledTransactionId: TransactionId?

  init(
    _ transactionId: TransactionId, _ nodeAccountId: AccountId, _ transactionHash: [UInt8],
    _ scheduledTransactionId: TransactionId?
  ) {
    self.transactionId = transactionId
    self.nodeAccountId = nodeAccountId
    self.transactionHash = transactionHash
    self.scheduledTransactionId = scheduledTransactionId
  }

  public func getTransactionId() -> TransactionId {
    transactionId
  }

  public func getNodeAccountId() -> AccountId {
    nodeAccountId
  }

  public func getTransactionHash() -> [UInt8] {
    transactionHash
  }

  public func getScheduledTransactionId() -> TransactionId? {
    scheduledTransactionId
  }
}
