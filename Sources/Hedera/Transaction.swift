import SwiftProtobuf
import Sodium
import Foundation
import GRPC
import NIO

typealias ExecuteClosure = (Proto_Transaction) throws -> Proto_TransactionResponse

let receiptInitialDelay: UInt32 = 1
let receiptRetryDelay: TimeInterval = 0.5

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

    func methodForTransaction(_ grpc: HederaGRPCClient) -> (Proto_Transaction, CallOptions?) -> UnaryCall<Proto_Transaction, Proto_TransactionResponse> {
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

    func executeAndWaitFor<T>(mapResponse: (TransactionReceipt) -> T) -> Result<T, HederaError> {
        let startTime = Date()
        var attempt: UInt8 = 0

        // There's no point asking for the receipt of a transaction that failed to go through
        switch execute() {
        case .failure(let error):
            return .failure(error)
        default:
            break
        }

        sleep(receiptInitialDelay)

        while true {
            attempt += 1
            
            let receipt = queryReceipt()
            switch receipt {
            case .success(let receipt):
                let receiptStatus = receipt.status

                if Int(receiptStatus) == Proto_ResponseCodeEnum.unknown.rawValue ||
                    receiptStatus == Proto_ResponseCodeEnum.ok.rawValue {
                    // stop trying if the delay will put us over `validDuration`
                    guard let delayUs = getReceiptDelayUs(startTime: startTime, attempt: attempt) else {
                        return .failure(HederaError(message: "executeForReceipt timed out"))
                    }

                    usleep(delayUs)
                } else {
                    return .success(mapResponse(receipt))
                }
            case .failure(let error):
                return .failure(error)
            }
        }
    }

    func getReceiptDelayUs(startTime: Date, attempt: UInt8) -> UInt32? {
        // exponential backoff algorithm:
        // next delay is some constant * rand(0, 2 ** attempt - 1)
        let delay = receiptRetryDelay
            * Double.random(in: 0..<Double((1 << attempt)))

        // if the next delay will put us past the valid duration we should stop trying
        let validDuration: TimeInterval = 2 * 60
        let expireInstant = startTime.addingTimeInterval(validDuration)
        if Date(timeIntervalSinceNow: delay).compare(expireInstant) == .orderedDescending {
            return nil
        }

        // converting from seconds to microseconds
        return UInt32(delay * 1000000)
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
    public func sign(with key: Ed25519PrivateKey) -> Self {
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
    
    public func execute() -> Result<TransactionId, HederaError> {
        do {
            return try executeAsync().wait()
        } catch {
            return .failure(HederaError(message: "RPC error: \(error)"))
        }
    }

    public func executeAsync() -> EventLoopFuture<Result<TransactionId, HederaError>> {
        guard let client = client else { fatalError("client must not be nil") }

        guard let node = client.nodes[nodeId] else {
            return client.eventLoopGroup.next().makeFailedFuture(HederaError(message: "node ID for transaction not found in Client"))
        }

        return methodForTransaction(client.grpcClient(for: node))(inner, nil).response.map { response -> Result<TransactionId, HederaError> in
            if response.nodeTransactionPrecheckCode == .ok {
                return .success(self.txId)
            } else {
                return .failure(HederaError(message: "preCheckCode was not OK: \(response.nodeTransactionPrecheckCode)"))
            }
        }
    }

    public func executeForReceipt() -> Result<TransactionReceipt, HederaError> {
        executeAndWaitFor { $0 }
    }

    public func queryReceipt() -> Result<TransactionReceipt, HederaError> {
        guard let client = client else { return .failure(HederaError(message: "client must not be nil")) }

        return TransactionReceiptQuery(client: client)
            .setTransactionId(txId)
            .execute()
    }
}
