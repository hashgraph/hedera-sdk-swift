import SwiftProtobuf
import Foundation

/// A transaction for deleting a contract
///
/// This transaction must be signed with the admin key to successfully delete the contract.
/// If the contract you wish to delete does not have an admin key set, then the contract is
/// essentially immutable and cannot be deleted.
public class ContractDeleteTransaction: TransactionBuilder {
    public override init() {
        super.init()

        body.contractDeleteInstance = Proto_ContractDeleteTransactionBody()
    }

    /// Set the contract to be deleted
    @discardableResult
    public func setContractId(_ id: ContractId) -> Self {
        body.contractDeleteInstance.contractID = id.toProto()

        return self
    }
}
