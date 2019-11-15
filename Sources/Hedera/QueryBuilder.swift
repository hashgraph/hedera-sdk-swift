import SwiftProtobuf
import Foundation
import GRPC
import NIO 

let maxQueryCost: Int64 = 10_000_000_000

typealias QueryExecuteClosure = (Proto_Query) throws -> Proto_Response

public class QueryBuilder<Response> {
    var body = Proto_Query()
    let client: Client
    var header = Proto_QueryHeader()
    var node: Node
    var needsPayment: Bool { true }

    init(client: Client) {
        self.client = client
        self.node = client.node ?? client.pickNode()
    }

    @discardableResult
    public func setPayment(_ amount: UInt64) -> Self {
        header.payment = CryptoTransferTransaction(client: client)
            .setNodeAccount(node.accountId)
            .add(recipient: node.accountId, amount: amount)
            .add(sender: client.operator!.id, amount: amount)
            .setMaxTransactionFee(100_000_000)
            .build()
            .addSigPair(publicKey: client.operator!.publicKey,
                        signer: client.operator!.signer)
            .toProto()

        return self
    }

    @discardableResult
    public func setPayment(_ transaction: Transaction) -> Self {
        header.payment = transaction.toProto()

        return self
    }

    @discardableResult
    public func requestCost() -> Result<UInt64, HederaError> {
        let responseType = header.responseType
        let payment = header.payment

        // Reset the responseType and payment of header
        defer {
            header.responseType = responseType
            header.payment = payment
        }

        header.responseType = Proto_ResponseType.costAnswer
        setPayment(0)

        do {
            return try methodForQuery(client.grpcClient(for: node))(body, nil).response.map { (response) -> Result<UInt64, HederaError> in
                let header = self.getResponseHeader(response)
                let preCheckCode = header.nodeTransactionPrecheckCode
                if preCheckCode != .ok && preCheckCode != .success {
                    return .failure(HederaError(message: "Received error code: \(header.nodeTransactionPrecheckCode) while requesting query cost"))
                } else {
                    return .success(header.cost)
                }
            }.wait()
        } catch let error {
            return .failure(HederaError(message: "failed to get cost for query: \(error)"))
        }
        
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
        default: fatalError("unrecognized query response header")
        }
    }

    func methodForQuery(_ grpc: HederaGRPCClient) -> (Proto_Query, CallOptions?) -> UnaryCall<Proto_Query, Proto_Response> {
        switch body.query {
        case .none:
            fatalError("tried to execute empty query")
        case .contractCallLocal:
            return grpc.contractService.contractCallLocalMethod
        case .getByKey:
            fatalError("missing getByKey?")
        case .getBySolidityID:
            return grpc.contractService.getBySolidityID
        case .contractGetInfo:
            return grpc.contractService.getContractInfo
        case .contractGetBytecode:
            return grpc.contractService.contractGetBytecode
        case .contractGetRecords:
            fatalError("missing contractGetRecords?")
        case .cryptogetAccountBalance:
            return grpc.cryptoService.cryptoGetBalance
        case .cryptoGetAccountRecords:
            return grpc.cryptoService.getAccountRecords
        case .cryptoGetInfo:
            return grpc.cryptoService.getAccountInfo
        case .cryptoGetClaim:
            return grpc.cryptoService.getClaim
        case .cryptoGetProxyStakers:
            // NOTE: this not yet implemented
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

    public func execute() -> Result<Response, HederaError> {
        do {
            return try executeAsync().wait()
        } catch {
            return .failure(HederaError(message: "RPC error: \(error)"))
        }
    }

    public func executeAsync() -> EventLoopFuture<Result<Response, HederaError>> {
        if needsPayment && !header.hasPayment {
            switch requestCost() {
            case .success(let cost):
                if let maxQueryPayment = client.maxQueryPayment {
                    if cost > maxQueryPayment {
                        return client.eventLoopGroup.next().makeFailedFuture(HederaError(message: "Query payment exceeds maxQueryPayment set on the client"))
                    }
                }

                setPayment(cost)
            case .failure(let error):
                return client.eventLoopGroup.next().makeFailedFuture(error)
            }
        }

        return client.eventLoopGroup.next().submit {
            let startTime = Date()
            var attempt: UInt8 = 0

            sleep(Backoff.initialDelay)

            while(true) {
                attempt += 1
            
                let response = Result { try self.methodForQuery(self.client.grpcClient(for: self.node))(self.body, nil).response.wait() }
                switch response {
                case .success(let response):
                    let header = self.getResponseHeader(response)
                    let precheck = header.nodeTransactionPrecheckCode

                    if precheck == .ok || precheck == .success {
                        return self.mapResponse(response)

                    } else if self.shouldRetry(precheck) {
                         // stop trying if the delay will put us over `validDuration`
                        guard let delayUs = Backoff.getDelayUs(startTime: startTime, attempt: attempt) else {
                            return .failure(HederaError(message: "execute timed out"))
                        }

                        usleep(delayUs)
                    } else {
                        return .failure(HederaError(message: "preCheckCode was not OK: \(precheck)"))
                    }
                case .failure(let error):
                    return .failure(HederaError(message: "\(error)"))
                }
            }
        }
    }

    func shouldRetry(_ precheckCode: Proto_ResponseCodeEnum) -> Bool {
        precheckCode == .busy
    }

    func mapResponse(_ response: Proto_Response) -> Result<Response, HederaError> {
        fatalError("mapResponse member must be overridden")
    }

    func toProto() -> Proto_Query {
        body
    }
}
