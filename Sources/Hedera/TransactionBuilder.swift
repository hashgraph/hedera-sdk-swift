import SwiftProtobuf
import Foundation

// Transactions are only valid for 2 minutes
let maxValidDuration = TimeInterval(2 * 60)

public class TransactionBuilder {
    var body = Proto_TransactionBody()

    // TODO: set transactionValidDuration to max
    // TODO: set transactionFee to something? Client.maxTransactionFee?

    public func setTransactionId(_ id: TransactionId) -> Self {
        body.transactionID = id.toProto()
        return self
    }

    public func setNodeAccount(_ id: AccountId) -> Self {
        body.nodeAccountID = id.toProto()
        return self
    }

    public func setTransactionFee(_ fee: UInt64) -> Self {
        body.transactionFee = fee
        return self
    }

    public func setTransactionValidDuration(_ duration: TimeInterval) -> Self {
        body.transactionValidDuration = duration.toProto()
        return self
    }

    public func setGenerateRecord(_ generateRecord: Bool) -> Self {
        body.generateRecord = generateRecord
        return self
    }

    public func setMemo(_ memo: String) -> Self {
        body.memo = memo
        return self
    }

    public func build() -> Transaction {
        var tx = Proto_Transaction()
        tx.body = body

        return Transaction(tx)
    }
}
