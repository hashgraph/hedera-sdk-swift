import SwiftProtobuf
import Foundation

// Transactions are only valid for 2 minutes
let maxValidDuration = TimeInterval(2 * 60)

public class TransactionBuilder {
    var body = Proto_TransactionBody()

    public func setMemo(_ memo: String) -> Self {
        body.memo = memo

        return self
    }

    public func build() -> Transaction {
        var tx = Proto_Transaction()
        tx.body = body

        return Transaction(inner: tx)
    }
}
