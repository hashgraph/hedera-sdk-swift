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

    /// Add an Ed25519 signature pair to the signature map
    @discardableResult
    func addSigPair(publicKey: Ed25519PublicKey, signature: Bytes) -> Self {
        var sigPair = Proto_SignaturePair()
        sigPair.pubKeyPrefix = Data(publicKey.bytes)
        sigPair.ed25519 = Data(signature)

        inner.sigMap.sigPair.append(sigPair)

        return self
    }

    /// Add an Ed25519 signature pair to the signature map
    @discardableResult
    func addSigPair(publicKey: Ed25519PublicKey, signer: Signer) -> Self {
        var sigPair = Proto_SignaturePair()
        sigPair.pubKeyPrefix = Data(publicKey.bytes)
        sigPair.ed25519 = Data(signer(Bytes(inner.bodyBytes)))

        inner.sigMap.sigPair.append(sigPair)

        return self
    }

    func signWithOperator(client: Client) {
        guard let oper = client.operator else { return }

        addSigPair(publicKey: oper.publicKey, signer: oper.signer)
    }

    func innerExecute(
        eventLoop: EventLoop,
        client: Client,
        node: Node,
        startTime: Date,
        attempt: UInt8
    ) -> EventLoopFuture<TransactionId> {
        guard let delay = Backoff.getDelay(startTime: startTime, attempt: attempt) else {
            return eventLoop.makeFailedFuture(HederaError.timedOut)
        }

        let delayPromise = eventLoop.makePromise(of: Void.self)

        eventLoop.scheduleTask(in: delay) {
            delayPromise.succeed(())
        }

        return delayPromise.futureResult.flatMap {
            self.methodForTransaction(client.grpcClient(for: node))(self.inner, nil).response
        }.flatMap { resp in
            let code = resp.nodeTransactionPrecheckCode

            if code == .busy {
                return self.innerExecute(eventLoop: eventLoop, client: client, node: node, startTime: startTime, attempt: attempt + 1)
            }

            switch resultFromCode(code, success: { self.transactionId }) {
            case .success(let res):
                return eventLoop.makeSucceededFuture(res)
            case .failure(let err):
                return eventLoop.makeFailedFuture(err)
            }
        }
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

    @discardableResult
    public func signWith(publicKey: Ed25519PublicKey, signer: Signer) -> Self {
        addSigPair(publicKey: publicKey, signer: signer)
    }

    public func execute(client: Client) -> EventLoopFuture<TransactionId> {
        guard let node = client.network[nodeId] else {
            return client.eventLoopGroup
                .next()
                .makeFailedFuture(HederaError.message("node ID for transaction not found in Client"))
        }
        let eventLoop = client.eventLoopGroup.next()
        
        signWithOperator(client: client)

        return self.methodForTransaction(client.grpcClient(for: node))(self.inner, nil).response.flatMap { resp in
            let code = resp.nodeTransactionPrecheckCode

            if code == .busy {
                return self.innerExecute(eventLoop: eventLoop, client: client, node: node, startTime: Date(), attempt: 0)
            }

            switch resultFromCode(code, success: { self.transactionId }) {
            case .success(let res):
                return eventLoop.makeSucceededFuture(res)
            case .failure(let err):
                return eventLoop.makeFailedFuture(err)
            }
        }
    }
}
