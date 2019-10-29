import SwiftProtobuf
import Sodium
import Foundation
import SwiftGRPC

// TODO: this should probably be its own file, and possibly an enum instead
struct HederaError: Error {
    let message: String
}

typealias ExecuteClosure = (_ clinet: HederaGRPCClient, _ transaction: Proto_Transaction) throws -> Proto_TransactionResponse 

//let RECEIPT_INITIAL_DELAY: UInt32 = 1

public class Transaction {
    var inner: Proto_Transaction
    let txId: TransactionId
    var client: Client?
    let executeClosure: ExecuteClosure
    
    init(_ client: Client, _ tx: Proto_Transaction, _ txId: Proto_TransactionID, _ closure: @escaping ExecuteClosure) {
        self.client = client
        inner = tx
        if !inner.hasSigMap { inner.sigMap = Proto_SignatureMap() }
        self.txId = TransactionId(txId)!
        executeClosure = closure
    }

    func toProto() -> Proto_Transaction {
        inner
    }

    public var bytes: Bytes {
        Bytes(inner.bodyBytes)
    }

    @discardableResult
    public func sign(with key: Ed25519PrivateKey) throws -> Self {
        let sig = key.sign(message: Bytes(inner.bodyBytes))
        
        return addSigPair(publicKey: key.publicKey, signature: sig)
    }
    
    /// Add an Ed25519 signature pair to the signature map
    @discardableResult
    public func addSigPair(publicKey: Ed25519PublicKey, signature: Bytes) -> Self {
        var sigPair = Proto_SignaturePair()
        sigPair.pubKeyPrefix = Data(publicKey.bytes)
        sigPair.ed25519 = Data(signature)

        inner.sigMap.sigPair.append(sigPair)
        
        return self
    }
    
    /// Add an Ed25519 signature pair to the signature map
    @discardableResult
    public func addSigPair(publicKey: Ed25519PublicKey, signer: (Bytes) -> Bytes) -> Self {
        var sigPair = Proto_SignaturePair()
        sigPair.pubKeyPrefix = Data(publicKey.bytes)
        sigPair.ed25519 = Data(signer(Bytes(inner.bodyBytes)))

        inner.sigMap.sigPair.append(sigPair)
        
        return self
    }
    
    public func execute() throws -> TransactionId {
        guard let client = client else { throw HederaError(message: "client must not be null") }
        
        
        if (inner.sigMap.sigPair.isEmpty) {
            guard let clientOperator = client.`operator` else { throw HederaError(message: "Client must have an operator set to execute") }
            addSigPair(publicKey: clientOperator.publicKey, signer: clientOperator.signer)
        }
            
        // TODO: actually handle error
        do {
            print("\(inner)")
            let response = try executeClosure(client.grpcClient(for: client.pickNode()), inner)
            if response.nodeTransactionPrecheckCode == .ok {
                return txId
            } else {
                throw HederaError(message: "preCheckCode was not OK: \(response.nodeTransactionPrecheckCode)")
            }
        } catch let err as CallError {
            throw HederaError(message: "CallError: \(err)")
        } catch let err as RPCError {
            throw HederaError(message: "RPCError: \(err)")
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
