import SwiftProtobuf
import Foundation

public struct TransactionId {
   let accountId: AccountId
   let transactionValidStart: Date
    
    public init(account id: AccountId) {
        accountId = id
        // Allow the transaction to be accepted as long as the 
        // server is not more than 10 seconds behind us
        transactionValidStart = Date(timeIntervalSinceNow: -10)
    }
}


extension TransactionId: ProtobufConvertible {
    typealias Proto = Proto_TransactionID

    func toProto() -> Proto {
        let proto = Proto()

        // TODO

        return proto
    }

    init?(_ proto: Proto) {
        // TODO
        return nil
    }
}
