import SwiftProtobuf
import Sodium
import Foundation
import GRPC
import NIO

typealias ExecuteClosure = (Proto_Transaction) throws -> Proto_TransactionResponse

public class Transaction {
    public let transactionId: TransactionId

    var inner: Proto_Transaction
    let nodeId: AccountId
    let kind: TransactionKind

    init(_ tx: Proto_Transaction) {
        let body = try! Proto_TransactionBody.init(serializedData: tx.bodyBytes)

        inner = tx
        if !inner.hasSigMap { inner.sigMap = Proto_SignatureMap() }
        transactionId = TransactionId(body.transactionID)!
        nodeId = AccountId(body.nodeAccountID)
        kind = TransactionKind(body.data!)
    }

    func methodForTransaction(_ grpc: HederaGRPCClient) ->
        (Proto_Transaction, CallOptions?) -> UnaryCall<Proto_Transaction, Proto_TransactionResponse> {
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

    // MARK: - Public API

    public convenience init?(bytes: Data) {
        guard let tx = try? Proto_Transaction.init(serializedData: bytes) else { return nil }
        guard (try? Proto_TransactionBody.init(serializedData: tx.bodyBytes)) != nil else { return nil }
        self.init(tx)
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

    public func execute(client: Client) -> Result<TransactionId, HederaError> {
        do {
            return try executeAsync(client: client).wait()
        } catch {
            return .failure(HederaError.message("RPC error: \(error)"))
        }
    }

    public func executeAsync(client: Client) -> EventLoopFuture<Result<TransactionId, HederaError>> {
        guard let node = client.network[nodeId] else {
            return client.eventLoopGroup
                .next()
                .makeFailedFuture(HederaError.message("node ID for transaction not found in Client"))
        }

        return client.eventLoopGroup.next().submit {
            let startTime = Date()
            var attempt: UInt8 = 0

            var delay = Backoff.initialDelay
            while true {
                // client.eventLoopGroup.next().scheduleTask(in: delay, task: () throws -> T)
                attempt += 1

                let response = Result {
                    try self.methodForTransaction(client.grpcClient(for: node))(self.inner, nil).response.wait()
                }
                switch response {
                case .success(let response):
                    switch response.nodeTransactionPrecheckCode {
                    case .busy:
                        // stop trying if the delay will put us over `validDuration`
                        guard let delayUs = Backoff.getDelayUs(startTime: startTime, attempt: attempt) else {
                            return .failure(HederaError.message("execute timed out"))
                        }

                        usleep(delayUs)
                    case .ok:
                        return .success(self.transactionId)
                    default:
                        return .failure(HederaError.message("preCheckCode was not OK: \(response.nodeTransactionPrecheckCode)"))
                    }
                case .failure(let error):
                    return .failure(HederaError.message("\(error)"))
                }
            }
        }
    }

    public func queryReceipt(client: Client) -> EventLoopFuture<Result<TransactionReceipt, HederaError>> {
        // guard let node = client.network[nodeId] else {
        //     return client.eventLoopGroup.next().makeFailedFuture
        //(HederaError.message("node ID for transaction not found in Client"))
        // }

        return TransactionReceiptQuery()
            .setTransaction(transactionId)
            .executeAsync(client: client)
    }

    public func queryRecord(client: Client) -> EventLoopFuture<Result<TransactionRecord, HederaError>> {
        // guard let node = client.network[nodeId] else {
        //     return client.eventLoopGroup.next().makeFailedFuture(Hedera
        //Error.message("node ID for transaction not found in Client"))
        // }

        return TransactionRecordQuery()
            .setTransaction(transactionId)
            .executeAsync(client: client)
    }
}
