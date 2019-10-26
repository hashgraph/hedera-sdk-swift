import SwiftProtobuf
import Foundation

// Transactions are only valid for 2 minutes
let maxValidDuration = TimeInterval(2 * 60)

public class TransactionBuilder {
    var body = Proto_TransactionBody()
    let client: Client?

    init(client: Client) {
        self.client = client
        body.transactionFee = client.maxTransactionFee
        body.transactionValidDuration = maxValidDuration.toProto()
    }
    
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

    // TODO: should this allow setting a longer duration than max?
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
    
    func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        fatalError("executeClosure member must be overridden")
    }

    public func build() -> Transaction {
        var tx = Proto_Transaction()
        tx.bodyBytes = try! body.serializedData()
        
        // TODO: perhaps handle a null client more gracefully, especially consider for testing
        return Transaction(client!, tx, executeClosure)
    }
}
