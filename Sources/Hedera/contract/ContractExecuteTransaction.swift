import SwiftProtobuf
import Foundation

public class ContractExecuteTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.contractCall = Proto_ContractCallTransactionBody()
    }

    @discardableResult
    public func setAmount(_ amount: UInt64) -> Self {
        body.contractCall.amount = Int64(amount)

        return self
    }

    @discardableResult
    public func setContract(_ id: ContractId) -> Self {
        body.contractCall.contractID = id.toProto()

        return self
    }

    @discardableResult
    public func setFunctionParameters(_ bytes: [UInt8]) -> Self {
        body.contractCall.functionParameters = Data(bytes)

        return self
    }

    @discardableResult
    public func setFunctionParameters(_ data: Data) -> Self {
        body.contractCall.functionParameters = data

        return self
    }

    @discardableResult
    public func setFunctionParameters(_ params: String) -> Self {
        body.contractCall.functionParameters = Data(Array(params.utf8))

        return self
    }

    @discardableResult
    public func setGas(_ gas: UInt64) -> Self {
        body.contractCall.gas = Int64(gas)

        return self        
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.contractService.contractCallMethod(tx)
    }
}
