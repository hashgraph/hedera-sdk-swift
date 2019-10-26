import SwiftProtobuf
import Foundation

public class ContractUpdateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.contractUpdateInstance = Proto_ContractUpdateTransactionBody()
    }

    @discardableResult
    public func setAdminKey(_ key: Ed25519PublicKey) -> Self {
        body.contractUpdateInstance.adminKey = key.toProto()

        return self
    }

    @discardableResult
    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.contractUpdateInstance.autoRenewPeriod = period.toProto()

        return self
    }

    @discardableResult
    public func setBytecodeFile(id: FileId) -> Self {
        body.contractUpdateInstance.fileID = id.toProto()

        return self
    }

    @discardableResult
    public func setContract(id: ContractId) -> Self {
        body.contractUpdateInstance.contractID = id.toProto()

        return self
    }

    @discardableResult
    public func setExpirationTime(date: Date) -> Self {
        body.fileCreate.expirationTime = date.toProto()

        return self
    }

    @discardableResult
    public func setProxyAccount(id: AccountId) -> Self {
        body.contractUpdateInstance.proxyAccountID = id.toProto()

        return self
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.contractService.createContract(tx)
    }
}
