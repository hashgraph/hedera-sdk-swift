import SwiftProtobuf
import Foundation

public class ContractUpdateTransaction: TransactionBuilder {
    /// Create a ContractUpdateTransaction
    ///
    /// This transaction must be signed with the admin key to successfully modify the contract
    /// If the contract you wish to update does not have an admin key set, then the contract is
    /// essentially immutable and cannot be changed in any way.
    public override init(client: Client? = nil) {
        super.init(client: client)

        body.contractUpdateInstance = Proto_ContractUpdateTransactionBody()
    }

    /// Set a new admin Ed25519PublicKey
    @discardableResult
    public func setAdminKey(_ key: Ed25519PublicKey) -> Self {
        body.contractUpdateInstance.adminKey = key.toProto()

        return self
    }

    /// Update or set the auto renew period in seconds
    @discardableResult
    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.contractUpdateInstance.autoRenewPeriod = period.toProto()

        return self
    }

    /// Update the solidity file to be used
    @discardableResult
    public func setBytecodeFile(_ id: FileId) -> Self {
        body.contractUpdateInstance.fileID = id.toProto()

        return self
    }

    /// Set the contract id to be updated
    @discardableResult
    public func setContract(_ id: ContractId) -> Self {
        body.contractUpdateInstance.contractID = id.toProto()

        return self
    }

    /// Update the expiration time
    ///
    /// Extend the expiration of the instance and its account to this time 
    /// (no effect if it already is this time or later)
    @discardableResult
    public func setExpirationTime(_ date: Date) -> Self {
        body.fileCreate.expirationTime = date.toProto()

        return self
    }

    /// Update or set the proxy account id
    ///
    /// - SeeAlso:
    ///     `ContractCreateTransaction::setProxyAccount`
    @discardableResult
    public func setProxyAccount(_ id: AccountId) -> Self {
        body.contractUpdateInstance.proxyAccountID = id.toProto()

        return self
    }
}
