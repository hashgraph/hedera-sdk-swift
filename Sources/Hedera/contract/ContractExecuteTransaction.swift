import SwiftProtobuf
import Foundation
import Sodium

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
    public func setContract(id: ContractId) -> Self {
        body.contractCall.contractID = id.toProto()

        return self
    }

    @discardableResult
    public func setFunctionParameters(bytes: Bytes) -> Self {
        body.contractCall.functionParameters = Data(bytes)

        return self
    }

    @discardableResult
    public func setFunctionParameters(arrayOfBytes: [Bytes]) -> Self {
        var data = Data()

        for bytes in arrayOfBytes {
            data.append(contentsOf: bytes)
        }

        body.contractCall.functionParameters = Data(data)

        return self
    }


    @discardableResult
    public func setFunctionParameters(data: Data) -> Self {
        body.contractCall.functionParameters = Data(data)

        return self
    }

    @discardableResult
    public func setFunctionParameters(string: String) -> Self {
        body.contractCall.functionParameters = Data(Array(string.utf8))

        return self
    }

    @discardableResult
    public func setFunctionParameters(strings: [String]) -> Self {
        var data = Data()

        for string in strings {
            data.append(contentsOf: Array(string.utf8))
        }

        body.contractCall.functionParameters = Data(data)

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
