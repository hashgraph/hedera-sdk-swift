import SwiftProtobuf
import Foundation

// Transactions are only valid for 2 minutes
let maxValidDuration = TimeInterval(2 * 60)

public class TransactionBuilder {
    var body = Proto_TransactionBody()
    let client: Client?

    init(client: Client? = nil) {
        self.client = client
        body.transactionValidDuration = maxValidDuration.toProto()
    }
    
    @discardableResult
    public func setTransactionId(_ id: TransactionId) -> Self {
        body.transactionID = id.toProto()
        return self
    }

    @discardableResult
    public func setNodeAccount(_ id: AccountId) -> Self {
        body.nodeAccountID = id.toProto()
        return self
    }

    @discardableResult
    public func setMaxTransactionFee(_ fee: UInt64) -> Self {
        body.transactionFee = fee
        return self
    }

    // TODO: should this allow setting a longer duration than max?
    @discardableResult
    public func setTransactionValidDuration(_ duration: TimeInterval) -> Self {
        body.transactionValidDuration = duration.toProto()
        return self
    }

    @discardableResult
    public func setGenerateRecord(_ generateRecord: Bool) -> Self {
        body.generateRecord = generateRecord
        return self
    }

    @discardableResult
    public func setMemo(_ memo: String) -> Self {
        body.memo = memo
        return self
    }

    public func build() -> Transaction {
        // If we have a client, set some defaults if they have not already been set
        if let client = client {
            if body.transactionFee == 0 {
                body.transactionFee = client.maxTransactionFee
            }

            if !body.hasTransactionID {
                setTransactionId(TransactionId(account: client.operator!.id))
            }
            
            if !body.hasTransactionValidDuration {
                setTransactionValidDuration(maxValidDuration)
            }
            
            if !body.hasNodeAccountID {
                let node = client.node ?? client.pickNode()
                setNodeAccount(node.accountId)
            }
        }
                
        var tx = Proto_Transaction()
        tx.body = body
        tx.bodyBytes = try! body.serializedData()
        
        // TODO: perhaps handle a null client more gracefully, especially consider for testing
        return Transaction(client!, tx, body.transactionID)

    }
}
