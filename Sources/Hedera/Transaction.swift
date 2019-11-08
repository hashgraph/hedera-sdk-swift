import SwiftProtobuf
import Sodium
import Foundation
import SwiftGRPC

typealias ExecuteClosure = (Proto_Transaction) throws -> Proto_TransactionResponse

let RECEIPT_INITIAL_DELAY: UInt32 = 1
let RECEIPT_RETRY_DELAY: TimeInterval = 0.5

public class Transaction {
    var inner: Proto_Transaction
    var client: Client?
    let txId: TransactionId
    let nodeId: AccountId
    let kind: TransactionKind

    init(_ client: Client?, _ tx: Proto_Transaction) {
        let body = try! Proto_TransactionBody.init(serializedData: tx.bodyBytes)
        
        self.client = client
        inner = tx
        if !inner.hasSigMap { inner.sigMap = Proto_SignatureMap() }
        txId = TransactionId(body.transactionID)!
        nodeId = AccountId(body.nodeAccountID)
        kind = TransactionKind(body.data!)
    }

    func methodForTransaction(_ grpc: HederaGRPCClient) -> ExecuteClosure {
        switch kind {
        case .contractCall:
            return grpc.contractService.contractCallMethod
        case .contractCreate:
            return grpc.contractService.createContract
        case .contractUpdate:
            return grpc.contractService.updateContract
        case .contractDelete:
            return grpc.contractService.deleteContract
        case .accountAddClaim:
            return grpc.cryptoService.addClaim
        case .accountCreate:
            return grpc.cryptoService.createAccount
        case .accountDelete:
            return grpc.cryptoService.cryptoDelete
        case .accountDeleteClaim:
            return grpc.cryptoService.deleteClaim
        case .cryptoTransfer:
            return grpc.cryptoService.cryptoTransfer
        case .accountUpdate:
            return grpc.cryptoService.updateAccount
        case .fileAppend:
            return grpc.fileService.appendContent
        case .fileCreate:
            return grpc.fileService.createFile
        case .fileDelete:
            return grpc.fileService.deleteFile
        case .fileUpdate:
            return grpc.fileService.updateFile
        case .systemDelete:
            return grpc.fileService.systemDelete
        case .systemUndelete:
            return grpc.fileService.systemUndelete
        }
    }

    func toProto() -> Proto_Transaction {
        inner
    }

    func executeAndWaitFor<T>(mapResponse: (TransactionReceipt) throws -> T) throws -> T {
        let startTime = Date()
        var attempt: UInt8 = 0
        let _ = try execute()

        sleep(RECEIPT_INITIAL_DELAY)

        while true {
            attempt += 1
            let receipt = try queryReceipt()
            let receiptStatus = receipt.status

            // TODO: check status and use exponential backoff
            if Int(receiptStatus) == Proto_ResponseCodeEnum.unknown.rawValue || receiptStatus == Proto_ResponseCodeEnum.ok.rawValue {
                // throw if the delay will put us over `validDuration`
                guard let delayUs = getReceiptDelayUs(startTime: startTime, attempt: attempt) else {
                    throw HederaError(message: "timed out") // TODO: better error message
                }

                usleep(delayUs)
            } else {
                // TODO: throw error if the response code is bad
                return try mapResponse(receipt)
            }
        }

    }
    
    func getReceiptDelayUs(startTime: Date, attempt: UInt8) -> UInt32? {
        // exponential backoff algorithm:
        // next delay is some constant * rand(0, 2 ** attempt - 1)
        let delay = RECEIPT_RETRY_DELAY
            * Double.random(in: 0..<Double((1 << attempt)))

        // if the next delay will put us past the valid duration we should stop trying
        // TODO: use the validDuration specified in the transaction
        let validDuration: TimeInterval = 2 * 60
        if Date(timeIntervalSinceNow: delay).compare(startTime.addingTimeInterval(validDuration)) == .orderedDescending {
            return nil
        }

        // converting from seconds to microseconds
        return UInt32(delay * 1000000)
    }

    func queryReceipt() throws -> TransactionReceipt {
        guard let client = client else { throw HederaError(message: "client must not be nil") }

        return try TransactionReceiptQuery(client: client)
            .setTransactionId(txId)
            .execute();
    }
    
    // MARK: - Public API

    public convenience init?(_ client: Client?, bytes: Data) {
        guard let tx = try? Proto_Transaction.init(serializedData: bytes) else { return nil }
        guard (try? Proto_TransactionBody.init(serializedData: tx.bodyBytes)) != nil else { return nil }
        self.init(client, tx)
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
        guard let client = client else { throw HederaError(message: "client must not be nil") }
        guard let node = client.nodes[nodeId] else { throw HederaError(message: "node ID for transaction not found in Client") }

        // TODO: actually handle error
        do {
            let response = try methodForTransaction(client.grpcClient(for: node))(inner)
            if response.nodeTransactionPrecheckCode == .ok {
                return txId
            } else {
                throw HederaError(message: "preCheckCode was not OK: \(response.nodeTransactionPrecheckCode)")
            }
        } catch let err {
            throw HederaError(message: "Error when executing transaction: \(err)")
        }
    }
    
    // TODO: public func executeAsync that takes a callback function
    
    public func executeForReceipt() throws -> TransactionReceipt {
        try executeAndWaitFor { $0 }
    }
    
    // TODO: public func executeForReceiptAsync that takes a callback function
}
