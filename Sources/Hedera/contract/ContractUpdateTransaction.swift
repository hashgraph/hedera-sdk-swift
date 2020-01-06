import SwiftProtobuf
import Foundation

public class ContractUpdateTransaction: TransactionBuilder {
    /// Create a ContractUpdateTransaction
    ///
    /// This transaction must be signed with the admin key to successfully modify the contract
    /// If the contract you wish to update does not have an admin key set, then the contract is
    /// essentially immutable and cannot be changed in any way.
    public override init() {
        super.init()

        body.contractUpdateInstance = Proto_ContractUpdateTransactionBody()
    }

    /// Set the contract id to be updated
    @discardableResult
    public func setContractId(_ id: ContractId) -> Self {
        body.contractUpdateInstance.contractID = id.toProto()

        return self
    }

    /// Set a new admin PublicKey
    @discardableResult
    public func setAdminKey(_ key: PublicKey) -> Self {
        body.contractUpdateInstance.adminKey = key.toProto()

        return self
    }

    /// Update or set the proxy account id
    ///
    /// - SeeAlso:
    ///     `ContractCreateTransaction::setProxyAccount`
    @discardableResult
    public func setProxyAccountId(_ id: AccountId) -> Self {
        body.contractUpdateInstance.proxyAccountID = id.toProto()

        return self
    }

    /// Update the solidity file to be used
    @discardableResult
    public func setBytecodeFileId(_ id: FileId) -> Self {
        body.contractUpdateInstance.fileID = id.toProto()

        return self
    }

    /// Update or set the auto renew period in seconds
    @discardableResult
    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.contractUpdateInstance.autoRenewPeriod = period.toProto()

        return self
    }

    /// Update the expiration time
    ///
    /// Extend the expiration of the instance and its account to this time 
    /// (no effect if it already is this time or later)
    @discardableResult
    public func setExpirationTime(_ date: Date) -> Self {
        body.contractUpdateInstance.expirationTime = date.toProto()

        return self
    }

    /// Set or update the memo for the contract
    @discardableResult
    public func setContractMemo(_ memo: String) -> Self {
        body.contractUpdateInstance.memo = memo

        return self
    }
}
