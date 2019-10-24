import SwiftProtobuf
import Sodium
import Foundation
import SwiftGRPC

// TODO: this should probably be its own file, and possibly an enum instead
struct HederaError: Error {}

//let RECEIPT_INITIAL_DELAY: UInt32 = 1

public class Transaction {
    var inner: Proto_Transaction
    let txId: TransactionId
    var client: Client?
    let executeClosure: (inout Client, Proto_Transaction) throws -> Proto_TransactionResponse

    init(_ client: Client, _ tx: Proto_Transaction, _ closure: @escaping (inout Client, Proto_Transaction) throws -> Proto_TransactionResponse) {
        self.client = client
        inner = tx
        txId = TransactionId(tx.body.transactionID)!
        executeClosure = closure
    }
    
    func toProto() -> Proto_Transaction {
        inner
    }

    var bytes: Bytes {
        Bytes(inner.bodyBytes)
    }

    // TODO: definitely test this function to make sure this works as it should
    public func sign(with key: Ed25519PrivateKey) throws -> Self {
        if !inner.hasSigMap { inner.sigMap = Proto_SignatureMap() }
        
        let pubKey = key.publicKey.bytes

        if inner.sigMap.sigPair.contains(where: { (sig) in 
            let pubKeyPrefix = sig.pubKeyPrefix
            return pubKey.starts(with: pubKeyPrefix)
        }) {
            // Transaction was already signed with this key!
            throw HederaError()
        }

        let sig = key.sign(message: Bytes(inner.bodyBytes))
        var sigPair = Proto_SignaturePair()
        sigPair.pubKeyPrefix = Data(pubKey)
        sigPair.ed25519 = Data(sig)

        inner.sigMap.sigPair.append(sigPair)

        return self
    }
    
    public func execute() throws -> TransactionId {
        guard var client = client else { throw HederaError() }
            
        // TODO: actually handle error
        if let response = try? executeClosure(&client, inner), response.nodeTransactionPrecheckCode == .ok {
            return txId
        } else {
            throw HederaError()
        }
    }
    
//    private func executeAndWaitFor<T>(mapResponse: (Proto_TransactionReceipt) throws -> T) throws -> T {
//        let startTime = Date()
//        var attempt = 0
//        try execute()
//
//        sleep(RECEIPT_INITIAL_DELAY)
//
//        while true {
//            attempt += 1
//          let receipt = queryReceipt()
//          let receiptStatus = receipt.status()
//
//            // TODO: check status and use exponential backoff
//        }
//
//    }
//
//    public func queryReceipt() throws -> TransactionReceipt {
//        // TODO: better error for empty client
//        guard let client = client else { throw HederaError() }
//
//        return TransactionReceiptQuery(client)
//            .setTransactionId(getId())
//            .execute();
//    }
}
