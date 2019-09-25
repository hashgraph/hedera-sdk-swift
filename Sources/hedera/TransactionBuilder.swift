import SwiftProtobuf
import Foundation

// Transactions are only valid for 2 minutes
let maxValidDuration = TimeInterval(2 * 60)

struct TransactionBuilder<T> where T: ProtobufConvertible {
    let inner = Proto_Transaction()
    let body = Proto_TransactionBody()


}

