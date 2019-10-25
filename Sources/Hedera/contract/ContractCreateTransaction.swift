import SwiftProtobuf
import Foundation

public class ContractCreateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.contractCreateInstance = Proto_ContractCreateTransactionBody()
    }

    @discardableResult
    public func setAdminKey(_ key: Ed25519PublicKey) -> Self {
        body.contractCreateInstance.adminKey = key.toProto()

        return self
    }

    @discardableResult
    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.contractCreateInstance.autoRenewPeriod = period.toProto()

        return self
    }


    @discardableResult
    public func setBytecodeFile(_ id: FileId) -> Self {
        body.contractCreateInstance.fileID = id.toProto()

        return self
    }

    @discardableResult
    public func setConstuctorParams(_ bytes: [UInt8]) -> Self {
        body.contractCreateInstance.constructorParameters = Data(bytes)

        return self
    }
    
    @discardableResult
    public func setGas(_ gas: UInt64) -> Self {
        body.contractCreateInstance.gas = Int64(gas)

        return self        
    }

    @discardableResult
    public func setInitialBalance(_ balance: UInt64) -> Self {
        body.contractCreateInstance.initialBalance = Int64(balance)

        return self
    }

    @discardableResult
    public func setProxyAccount(_ id: AccountId) -> Self {
        body.contractCreateInstance.proxyAccountID = id.toProto()

        return self
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.contractService.createContract(tx)
    }
}
