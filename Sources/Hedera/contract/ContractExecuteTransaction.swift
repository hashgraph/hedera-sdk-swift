import SwiftProtobuf
import Foundation

public class ContractExecuteTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.contractCall = Proto_ContractCallTransactionBody()
    }

    public func setAmount(_ amount: Int64) -> Self {
        body.contractCall.amount = amount

        return self
    }

    public func setFunctionParameters(_ bytes: [UInt8]) -> Self {
        body.contractCall.functionParameters = Data(bytes)

        return self
    }

    public func setFunctionParameters(_ data: Data) -> Self {
        body.contractCall.functionParameters = data

        return self
    }

    public func setFunctionParameters(_ params: String) -> Self {
        body.contractCall.functionParameters = Data(Array(params.utf8))

        return self
    }

    public func setGas(_ gas: Int64) -> Self {
        body.contractCall.gas = gas

        return self        
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.contractService.contractCallMethod(tx)
    }
}
