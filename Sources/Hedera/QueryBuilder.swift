import SwiftProtobuf
import Foundation

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
        self.node = client.pickNode()
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

        let responseHeader = Result { try methodForQuery(client.grpcClient(for: node))(body) }
            .map { getResponseHeader($0) }

        switch responseHeader {
        case .success(let header):
            let preCheckCode = header.nodeTransactionPrecheckCode
            if preCheckCode != .ok && preCheckCode != .success {
                return .failure(HederaError(
                    message: "received error code: \(preCheckCode) while requesting query cost"
                ))
            }

            return .success(header.cost)
        case .failure(let error as HederaError):
            return .failure(error)
        case .failure(let error):
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

    func methodForQuery(_ grpc: HederaGRPCClient) -> QueryExecuteClosure {
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
        if needsPayment && !header.hasPayment {
            switch requestCost() {
            case .success(let cost):
                if let maxQueryPayment = client.maxQueryPayment {
                    if cost > maxQueryPayment {
                        return .failure(HederaError(message: "Query payment exceeds maxQueryPayment"))
                    }
                }

                setPayment(cost)
            case .failure(let error):
                return .failure(error)
            }
        }

        do {
            let response = try methodForQuery(client.grpcClient(for: node))(body)
            
            let resHeader = getResponseHeader(response)

            if resHeader.nodeTransactionPrecheckCode != .ok && resHeader.nodeTransactionPrecheckCode != .success {
                return .failure(HederaError(message: "Received error code: \(resHeader.nodeTransactionPrecheckCode) while executing"))
            }

            return mapResponse(response)
        } catch let error {
            // FIXME
            return .failure(HederaError(message: "error: \(error)"))
        }
    }

    func mapResponse(_ response: Proto_Response) -> Result<Response, HederaError> {
        fatalError("mapResponse member must be overridden")
    }

    func toProto() -> Proto_Query {
        body
    }
}
