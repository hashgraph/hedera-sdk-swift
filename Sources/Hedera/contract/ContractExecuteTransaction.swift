import SwiftProtobuf
import Foundation
import Sodium

public class ContractExecuteTransaction: TransactionBuilder {
    public override init() {
        super.init()

        body.contractCall = Proto_ContractCallTransactionBody()
    }

    /// Set amount of tinybars to be sent
    ///
    /// The function must be payable to use this method
    @discardableResult
    public func setAmount(_ amount: UInt64) -> Self {
        body.contractCall.amount = Int64(amount)

        return self
    }

    /// Set the contract id to be executed
    @discardableResult
    public func setContractId(_ id: ContractId) -> Self {
        body.contractCall.contractID = id.toProto()

        return self
    }

    /// Set the function parameters to the contract
    ///
    /// Function parameters must be encoded in solidity format
    @discardableResult
    public func setFunctionParameters(_ bytes: Bytes) -> Self {
        body.contractCall.functionParameters = Data(bytes)

        return self
    }

    /// Set the function parameters to the contract
    ///
    /// Function parameters must be encoded in solidity format
    @discardableResult
    public func setFunctionParameters(_ data: Data) -> Self {
        body.contractCall.functionParameters = Data(data)

        return self
    }

    /// Set the maximum amount of tinybars to be used to execute the contract
    ///
    /// Although the type of `gas` is UInt64, the valid range is [0, 2^63-1]
    @discardableResult
    public func setGas(_ gas: UInt64) -> Self {
        body.contractCall.gas = Int64(gas)

        return self
    }
}
