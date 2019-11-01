import SwiftProtobuf
import Foundation

public class ContractDeleteTransaction: TransactionBuilder {
    /// Create a ContractDeleteTransaction
    ///
    /// This transaction must be signed with the admin key to successfully delete the contract
    /// If the contract you wish to delete does not have an admin key set, then the contract is
    /// essentially immutable and cannot be deleted.
    public override init(client: Client) {
        super.init(client: client)

        body.contractDeleteInstance = Proto_ContractDeleteTransactionBody()
    }

    /// Set the contract id to be deleted
    @discardableResult
    public func setContract(_ id: ContractId) -> Self {
        body.contractDeleteInstance.contractID = id.toProto()

        return self
    }

//    override static func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
//        try grpc.contractService.deleteContract(tx)
//    }
}
