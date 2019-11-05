import SwiftProtobuf
import Sodium
import Foundation
import SwiftGRPC

// TODO: this should probably be its own file, and possibly an enum instead
struct HederaError: Error {
    let message: String
}

typealias ExecuteClosure = (Proto_Transaction) throws -> Proto_TransactionResponse

//let RECEIPT_INITIAL_DELAY: UInt32 = 1

public class Transaction {
    var inner: Proto_Transaction
    let txId: TransactionId
    var client: Client?

    init(_ client: Client?, _ tx: Proto_Transaction, _ txId: Proto_TransactionID) {
        self.client = client
        inner = tx
        if !inner.hasSigMap { inner.sigMap = Proto_SignatureMap() }
        self.txId = TransactionId(txId)!
    }

    convenience init?(_ client: Client?, bytes: Data) {
        guard let tx = try? Proto_Transaction.init(serializedData: bytes) else { return nil }
        guard let body = try? Proto_TransactionBody.init(serializedData: tx.bodyBytes) else { return nil }
        self.init(client!, tx, body.transactionID)
    }

    func methodForTransaction(_ grpc: HederaGRPCClient) -> ExecuteClosure {
        // swiftlint:disable:next force_try
        let body = try! Proto_TransactionBody.init(serializedData: inner.bodyBytes)

        switch body.data {
        case .none:
            fatalError()
        case .systemDelete:
            return grpc.fileService.systemDelete
        case .contractCall:
            return grpc.contractService.contractCallMethod
        case .contractCreateInstance:
            return grpc.contractService.createContract
        case .contractUpdateInstance:
            return grpc.contractService.updateContract
        case .contractDeleteInstance:
            return grpc.contractService.deleteContract
        case .cryptoAddClaim:
            return grpc.cryptoService.addClaim
        case .cryptoCreateAccount:
            return grpc.cryptoService.createAccount
        case .cryptoDelete:
            return grpc.cryptoService.cryptoDelete
        case .cryptoDeleteClaim:
            return grpc.cryptoService.deleteClaim
        case .cryptoTransfer:
            return grpc.cryptoService.cryptoTransfer
        case .cryptoUpdateAccount:
            return grpc.cryptoService.updateAccount
        case .fileAppend:
            return grpc.fileService.appendContent
        case .fileCreate:
            return grpc.fileService.createFile
        case .fileDelete:
            return grpc.fileService.deleteFile
        case .fileUpdate:
            return grpc.fileService.updateFile
        case .systemUndelete:
            return grpc.fileService.systemUndelete
        case .freeze:
            fatalError("TODO: freeze service")
        }
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
    public func addSigPair(publicKey: Ed25519PublicKey, signer: Signer) -> Self {
        var sigPair = Proto_SignaturePair()
        sigPair.pubKeyPrefix = Data(publicKey.bytes)
        sigPair.ed25519 = Data(signer(Bytes(inner.bodyBytes)))

        inner.sigMap.sigPair.append(sigPair)

        return self
    }

    public func execute() throws -> TransactionId {
        guard let client = client else { throw HederaError(message: "client must not be null") }

        if inner.sigMap.sigPair.isEmpty {
            guard let clientOperator = client.`operator` else {
                throw HederaError(message: "Client must have an operator set to execute")
            }
            addSigPair(publicKey: clientOperator.publicKey, signer: clientOperator.signer)
        }

        // TODO: actually handle error
        do {
            print("\(inner)")
            let response = try methodForTransaction(client.grpcClient(for: client.pickNode()))(inner)
            if response.nodeTransactionPrecheckCode == .ok {
                return txId
            } else {
                throw HederaError(message: "preCheckCode was not OK: \(response.nodeTransactionPrecheckCode)")
            }
        } catch let err {
            throw HederaError(message: "Error when executing transaction: \(err)")
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
