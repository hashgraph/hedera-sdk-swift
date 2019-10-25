import SwiftProtobuf
import Foundation

let maxQueryCost: Int64 = 10_000_000_000

public class QueryBuilder<Response> {
    var body = Proto_Query()
    let client: Client
    var header = Proto_QueryHeader()
    var node: Node

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
            .setTransactionFee(1)
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
    public func requestCost() throws -> UInt64 {
        let responseType = header.responseType
        let payment = header.payment

        // Reset the responseType and payment of header
        defer {
            header.responseType = responseType
            header.payment = payment
        }

        header.responseType = Proto_ResponseType.costAnswer
        setPayment(0)

        let response = try executeClosure(client.grpcClient(for: node))

        var resHeader: Proto_ResponseHeader
        switch response.response {
        case .getByKey(let res): resHeader = res.header
        case .getBySolidityID(let res): resHeader = res.header
        case .contractCallLocal(let res): resHeader = res.header
        case .contractGetBytecodeResponse(let res): resHeader = res.header
        case .contractGetInfo(let res): resHeader = res.header
        case .contractGetRecordsResponse(let res): resHeader = res.header
        case .cryptogetAccountBalance(let res): resHeader = res.header
        case .cryptoGetAccountRecords(let res): resHeader = res.header
        case .cryptoGetInfo(let res): resHeader = res.header
        case .cryptoGetClaim(let res): resHeader = res.header
        case .cryptoGetProxyStakers(let res): resHeader = res.header
        case .fileGetContents(let res): resHeader = res.header
        case .fileGetInfo(let res): resHeader = res.header
        case .transactionGetReceipt(let res): resHeader = res.header
        case .transactionGetRecord(let res): resHeader = res.header
        case .transactionGetFastRecord(let res): resHeader = res.header
        default: fatalError("requestCost received unrecognized response header")
        }

        if resHeader.nodeTransactionPrecheckCode != .ok 
            && resHeader.nodeTransactionPrecheckCode != .success {
            throw HederaError(
                message: "Received error code: \(resHeader.nodeTransactionPrecheckCode) while requesting query cost"
            )
        }

        return resHeader.cost
    }

    func executeClosure(
        _ grpc: HederaGRPCClient
    ) throws -> Proto_Response {
        fatalError("executeClosure member must be overridden")
    }

    public func execute() throws -> Response {
        // if let maxQueryPayment = client.maxQueryPayment, header.hasPayment {
            let cost = try requestCost()
            // if cost > maxQueryPayment {
            //     throw HederaError(message: "Query payment exceeds maxQueryPayment")
            // }

            setPayment(1_000_000_000)
        // }

        let response = try executeClosure(client.grpcClient(for: node))

        var resHeader: Proto_ResponseHeader
        switch response.response {
        case .getByKey(let res): resHeader = res.header
        case .getBySolidityID(let res): resHeader = res.header
        case .contractCallLocal(let res): resHeader = res.header
        case .contractGetBytecodeResponse(let res): resHeader = res.header
        case .contractGetInfo(let res): resHeader = res.header
        case .contractGetRecordsResponse(let res): resHeader = res.header
        case .cryptogetAccountBalance(let res): resHeader = res.header
        case .cryptoGetAccountRecords(let res): resHeader = res.header
        case .cryptoGetInfo(let res): resHeader = res.header
        case .cryptoGetClaim(let res): resHeader = res.header
        case .cryptoGetProxyStakers(let res): resHeader = res.header
        case .fileGetContents(let res): resHeader = res.header
        case .fileGetInfo(let res): resHeader = res.header
        case .transactionGetReceipt(let res): resHeader = res.header
        case .transactionGetRecord(let res): resHeader = res.header
        case .transactionGetFastRecord(let res): resHeader = res.header
        default: fatalError("execute received unrecognized response header")
        }

        if resHeader.nodeTransactionPrecheckCode != .ok && resHeader.nodeTransactionPrecheckCode != .success{
            throw HederaError(message: "Received error code: \(resHeader.nodeTransactionPrecheckCode) while executing")
        }

        return mapResponse(response)
    }

    func mapResponse(_ response: Proto_Response) -> Response {
        fatalError("mapResponse member must be overridden")
    }

    func toProto() -> Proto_Query {
        body
    }
}
