import SwiftProtobuf
import Foundation
import GRPC
import NIO

typealias QueryExecuteClosure = (Proto_Query) throws -> Proto_Response

public class QueryBuilder<R> {
    var body = Proto_Query()
    // var header = Proto_QueryHeader()
    var needsPayment: Bool { true }

    var maxQueryPayment: Hbar?
    var queryPayment: Hbar?

    init() {}

    @discardableResult
    public func setMaxQueryPayment(_ max: Hbar) -> Self {
        maxQueryPayment = max
        return self
    }

    @discardableResult
    public func setQueryPayment(_ amount: Hbar) -> Self {
        queryPayment = amount
        return self
    }

    @discardableResult
    public func setQueryPaymentTransaction(_ transaction: Transaction) -> Self {
        withHeader {
            $0.payment = transaction.toProto()
        }

        return self
    }

    @discardableResult
    func getCost(client: Client, node: Node) -> EventLoopFuture<Hbar> {
        // Store the current response type and payment
        let responseType = withHeader { $0.responseType }
        let payment = withHeader { $0.payment }

        // Reset the responseType and payment of header
        // at the end of the function
        defer {
            withHeader {
                $0.responseType = responseType
                $0.payment = payment
            }
        }

        withHeader {
            // COST_ANSWER tells HAPI to return only the cost for the given query
            $0.responseType = .costAnswer

            // COST_ANSWER requires a 0 payment and does not actually process it
            $0.payment = CryptoTransferTransaction()
                .addSender(client.operator!.id, amount: Hbar.ZERO)
                .addRecipient(node.accountId, amount: Hbar.ZERO)
                .build(client: client)
                .addSigPair(publicKey: client.operator!.publicKey, signer: client.operator!.signer)
                .toProto()
        }

        let eventLoop = client.eventLoopGroup.next()
        let successValueMapper = { Hbar.fromTinybar(amount: Int64(self.getResponseHeader($0).cost)) }

        return self.getQueryMethod(client.grpcClient(for: node))(self.body, nil)
            .response
            .flatMap { resp in
                let header = self.getResponseHeader(resp)
                let code = header.nodeTransactionPrecheckCode

                if self.shouldRetry(code) {
                    return self.innerExecute(
                        eventLoop: eventLoop,
                        client: client,
                        node: node,
                        startTime: Date(),
                        attempt: 0,
                        successValueMapper: successValueMapper
                    )
                }

                switch resultFromCode(code, success: { successValueMapper(resp) }) {
                case .success(let res):
                    return eventLoop.makeSucceededFuture(res)

                case .failure(let err):
                    return eventLoop.makeFailedFuture(err)
                }
            }
    }

    @discardableResult
    public func getCost(client: Client) -> EventLoopFuture<Hbar> {
        return getCost(client: client, node: client.pickNode())
    }

    func getResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
        switch response.response {
        case .getByKey(let res): return res.header
        case .getBySolidityID(let res): return res.header
        case .contractCallLocal(let res): return res.header
        case .contractGetBytecodeResponse(let res): return res.header
        case .contractGetInfo(let res): return res.header
        case .contractGetRecordsResponse(let res): return res.header
        case .cryptogetAccountBalance(let res): return res.header
        case .cryptoGetAccountRecords(let res): return res.header
        case .cryptoGetInfo(let res): return res.header
        case .cryptoGetClaim(let res): return res.header
        case .cryptoGetProxyStakers(let res): return res.header
        case .fileGetContents(let res): return res.header
        case .fileGetInfo(let res): return res.header
        case .transactionGetReceipt(let res): return res.header
        case .transactionGetRecord(let res): return res.header
        case .transactionGetFastRecord(let res): return res.header

        default: fatalError("unreachable: unknown query response")
        }
    }

    func getQueryMethod(
        _ grpc: HederaGRPCClient
    ) -> (Proto_Query, CallOptions?) -> UnaryCall<Proto_Query, Proto_Response> {
        switch body.query {
        case .none:
            fatalError("unreachable: nil query")
        case .contractCallLocal:
            return grpc.contractService.contractCallLocalMethod
        case .getByKey:
            fatalError("not implemented: GetByKeyQuery")
        case .getBySolidityID:
            return grpc.contractService.getBySolidityID
        case .contractGetInfo:
            return grpc.contractService.getContractInfo
        case .contractGetBytecode:
            return grpc.contractService.contractGetBytecode
        case .contractGetRecords:
            return grpc.contractService.getTxRecordByContractID
        case .cryptogetAccountBalance:
            return grpc.cryptoService.cryptoGetBalance
        case .cryptoGetAccountRecords:
            return grpc.cryptoService.getAccountRecords
        case .cryptoGetInfo:
            return grpc.cryptoService.getAccountInfo
        case .cryptoGetClaim:
            return grpc.cryptoService.getClaim
        case .cryptoGetProxyStakers:
            return grpc.cryptoService.getStakersByAccountID
        case .fileGetContents:
            return grpc.fileService.getFileContent
        case .fileGetInfo:
            return grpc.fileService.getFileInfo
        case .transactionGetReceipt:
            return grpc.cryptoService.getTransactionReceipts
        case .transactionGetRecord:
            return grpc.cryptoService.getTxRecordByTxID
        case .transactionGetFastRecord:
            return grpc.cryptoService.getFastTransactionRecord
        }
    }

    func generateQueryPaymentTransaction(client: Client, node: Node, amount: Hbar) {
        let tx = CryptoTransferTransaction()
            .setNodeAccountId(node.accountId)
            .addSender(client.operator!.id, amount: amount)
            .addRecipient(node.accountId, amount: amount)
            .setMaxTransactionFee(defaultMaxTransactionFee)
            .build(client: client)
            .addSigPair(publicKey: client.operator!.publicKey, signer: client.operator!.signer)

        setQueryPaymentTransaction(tx)
    }

    public func execute(client: Client) -> EventLoopFuture<R> {
        let eventLoop = client.eventLoopGroup.next()
        let nodeFut: EventLoopFuture<Node>

        if needsPayment {
            if withHeader({ $0.hasPayment }) {
                let txBytes = withHeader { $0.payment.bodyBytes }

                // We can be reasonably confident that the data bytes are valid
                let tx = try! Proto_Transaction(serializedData: txBytes)

                nodeFut = eventLoop.makeSucceededFuture(
                    client.network[AccountId(tx.body.nodeAccountID)]!)
            } else if let amount = queryPayment {
                let node = client.pickNode()

                generateQueryPaymentTransaction(client: client, node: node, amount: amount)

                nodeFut = eventLoop.makeSucceededFuture(node)
            } else {
                let node = client.pickNode()
                let maxAmount = maxQueryPayment ?? client.maxQueryPayment

                nodeFut = getCost(client: client).flatMapResult { (cost) -> Result<Node, HederaError> in
                    if cost > maxAmount {
                        return .failure(HederaError.queryPaymentExceedsMax)
                    }

                    self.generateQueryPaymentTransaction(client: client, node: node, amount: cost)

                    return .success(node)
                }
            }
        } else {
            nodeFut = eventLoop.makeSucceededFuture(client.pickNode())
        }

        // TODO: Sometime in the future run a local validator

        return nodeFut.flatMap { node in
            self.getQueryMethod(client.grpcClient(for: node))(self.body, nil)
                .response
                .flatMap { resp in
                    let header = self.getResponseHeader(resp)
                    let code = header.nodeTransactionPrecheckCode

                    if self.shouldRetry(code) {
                        return self.innerExecute(
                            eventLoop: eventLoop,
                            client: client,
                            node: node,
                            startTime: Date(),
                            attempt: 0,
                            successValueMapper: self.mapResponse
                        )
                    }

                    switch resultFromCode(code, success: { self.mapResponse(resp) }) {
                    case .success(let res):
                        return eventLoop.makeSucceededFuture(res)

                    case .failure(let err):
                        return eventLoop.makeFailedFuture(err)
                    }
                }
        }
    }

    func innerExecute<T>(
        eventLoop: EventLoop,
        client: Client,
        node: Node,
        startTime: Date,
        attempt: UInt8,
        successValueMapper: @escaping (Proto_Response) -> T
    ) -> EventLoopFuture<T> {
        guard let delay = Backoff.getDelay(startTime: startTime, attempt: attempt) else {
            return eventLoop.makeFailedFuture(HederaError.timedOut)
        }

        let delayPromise = eventLoop.makePromise(of: Void.self)

        eventLoop.scheduleTask(in: delay) {
            delayPromise.succeed(())
        }

        return delayPromise.futureResult.flatMap {
            self.getQueryMethod(client.grpcClient(for: node))(self.body, nil).response
        }.flatMap { resp in
            let header = self.getResponseHeader(resp)
            let code = header.nodeTransactionPrecheckCode

            print(" RECEIVED \(code)")

            if self.shouldRetry(code) {
                return self.innerExecute(
                    eventLoop: eventLoop,
                    client: client,
                    node: node,
                    startTime: startTime,
                    attempt: attempt + 1,
                    successValueMapper: successValueMapper
                )
            }

            switch resultFromCode(code, success: { successValueMapper(resp) }) {
            case .success(let res):
                return eventLoop.makeSucceededFuture(res)

            case .failure(let err):
                return eventLoop.makeFailedFuture(err)
            }
        }
    }

    func shouldRetry(_ precheckCode: Proto_ResponseCodeEnum) -> Bool {
        precheckCode == .busy
    }

    func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        fatalError("withHeader must be overriden")
    }

    func mapResponse(_ response: Proto_Response) -> R {
        fatalError("mapResponse member must be overridden")
    }

    func toProto() -> Proto_Query {
        body
    }
}
