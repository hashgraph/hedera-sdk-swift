import Foundation
import NIO

public final class TransactionResponse {
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

  public func getReceiptAsync(_ client: Client) -> EventLoopFuture<TransactionReceipt> {
    try! TransactionReceiptQuery()
      .setNodeAccountIds([nodeAccountId])
      .setTransactionId(transactionId)
      .executeAsync(client)
      .flatMap {
        if case .success = $0.status {
          return client.eventLoopGroup.next().makeSucceededFuture($0)
        } else {
          return client.eventLoopGroup.next().makeFailedFuture(
            ReceiptStatusError(transactionId: self.transactionId, receipt: $0))
        }
      }
  }
}

extension TransactionResponse: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    """
    transactionId: \(transactionId),
    nodeAccountId: \(nodeAccountId),
    transactionHash: \(transactionHash),
    scheduledTransactionId: \(String(describing: scheduledTransactionId)),
    """
  }
  public var debugDescription: String {
    description
  }
}
