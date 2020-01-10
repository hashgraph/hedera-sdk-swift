import SwiftProtobuf
import Foundation
import NIO

// Transactions are only valid for 2 minutes
let maxValidDuration = TimeInterval(2 * 60)

public class TransactionBuilder {
    var body = Proto_TransactionBody()

    init() {
        body.transactionValidDuration = maxValidDuration.toProto()
    }

    @discardableResult
    public func setTransactionId(_ id: TransactionId) -> Self {
        body.transactionID = id.toProto()

        return self
    }

    @discardableResult
    public func setMaxTransactionFee(_ fee: UInt64) -> Self {
        body.transactionFee = fee

        return self
    }

    @discardableResult
    public func setTransactionValidDuration(_ duration: TimeInterval) -> Self {
        body.transactionValidDuration = duration.toProto()

        return self
    }

    @discardableResult
    public func setTransactionMemo(_ memo: String) -> Self {
        body.memo = memo
        return self
    }

    /// Set the account of the node that will submit the transaction to the network.
    @discardableResult
    public func setNodeAccountId(_ id: AccountId) -> Self {
        body.nodeAccountID = id.toProto()
        return self
    }

    public func build(client: Client?) -> Transaction {
        // If we have a client, set some defaults if they have not already been set
        if let client = client {
            if body.transactionFee == 0 {
                body.transactionFee = client.maxTransactionFee
            }

            if !body.hasNodeAccountID {
                setNodeAccountId(client.pickNode().accountId)
            }

            if !body.hasTransactionID {
                setTransactionId(TransactionId(account: client.operator!.id))
            }
        }

        var tx = Proto_Transaction()
        tx.body = body
        tx.bodyBytes = try! body.serializedData()

        return Transaction(tx)
    }

    public func execute(client: Client) -> EventLoopFuture<Result<TransactionId, HederaError>> {
        build(client: client).executeAsync(client: client)
    }
}
