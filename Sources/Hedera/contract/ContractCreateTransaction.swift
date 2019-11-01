import SwiftProtobuf
import Foundation
import Sodium

public class ContractCreateTransaction: TransactionBuilder {
    public override init(client: Client? = nil) {
        super.init(client: client)

        body.contractCreateInstance = Proto_ContractCreateTransactionBody()
    }

    /// Set the admin Ed25519PublicKey. 
    ///
    /// The admin key is required to modify the contract. If the admin key is null, then 
    /// the contract becomes immutable and the only way to modify the contract would be to
    /// recreate it; this time with an admin key.
    @discardableResult
    public func setAdminKey(_ key: Ed25519PublicKey) -> Self {
        body.contractCreateInstance.adminKey = key.toProto()

        return self
    }

    /// Set the auto renew period in seconds for the to be created contract
    @discardableResult
    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.contractCreateInstance.autoRenewPeriod = period.toProto()

        return self
    }

    /// Set the file id for the solidity contract
    @discardableResult
    public func setBytecodeFile(_ id: FileId) -> Self {
        body.contractCreateInstance.fileID = id.toProto()

        return self
    }

    /// Set the contract constructor parameters in solidity format
    @discardableResult
    public func setConstructorParameters(_ bytes: Bytes) -> Self {
        body.contractCreateInstance.constructorParameters = Data(bytes)

        return self
    }

    /// Set the contract constructor parameters in solidity format
    @discardableResult
    public func setConstructorParameters(_ data: Data) -> Self {
        body.contractCreateInstance.constructorParameters = data

        return self
    }

    /// Set the amount of tinybars to be used to create the transaction
    ///
    /// Although the type of `gas` is UInt64, the valid range is [0, 2^63-1]
    @discardableResult
    public func setGas(_ gas: UInt64) -> Self {
        body.contractCreateInstance.gas = Int64(gas)

        return self        
    }

    /// Set the initial balance of a contract
    ///
    /// Although the type of `balance` is UInt64, the valid range is [0, 2^63-1]
    /// The contract will take ownership of the initial balance
    @discardableResult
    public func setInitialBalance(_ balance: UInt64) -> Self {
        body.contractCreateInstance.initialBalance = Int64(balance)

        return self
    }

    /// Set the proxy account
    ///
    /// ID of the account to which this account is proxy staked. If the ID is null, or is an 
    /// invalid account, or is an account that isn't a node, then this account is automatically proxy 
    /// staked to a node chosen by the network, but without earning payments. 
    @discardableResult
    public func setProxyAccount(_ id: AccountId) -> Self {
        body.contractCreateInstance.proxyAccountID = id.toProto()

        return self
    }

//    override static  func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
//        try grpc.contractService.createContract(tx)
//    }
}
