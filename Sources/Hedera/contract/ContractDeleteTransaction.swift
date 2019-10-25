import SwiftProtobuf
import Foundation

public class ContractDeleteTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.contractDeleteInstance = Proto_ContractDeleteTransactionBody()
    }

    @discardableResult
    public func setContract(_ id: ContractId) -> Self {
        body.contractDeleteInstance.contractID = id.toProto()

        return self
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.contractService.deleteContract(tx)
    }
}
