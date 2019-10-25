import SwiftProtobuf
import Foundation

public class ContractUpdateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.contractUpdateInstance = Proto_ContractUpdateTransactionBody()
    }

    public func setAdminKey(_ key: Ed25519PublicKey) -> Self {
        body.contractUpdateInstance.adminKey = key.toProto()

        return self
    }

    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.contractUpdateInstance.autoRenewPeriod = period.toProto()

        return self
    }

    public func setBytecodeFile(_ id: FileId) -> Self {
        body.contractUpdateInstance.fileID = id.toProto()

        return self
    }

    public func setContractId(_ id: ContractId) -> Self {
        body.contractUpdateInstance.contractID = id.toProto()

        return self
    }

    public func setExpirationTime(_ seconds: Int64, _ nanos: Int32) -> Self {
        var expirationTime = Proto_Timestamp()
        expirationTime.seconds = seconds
        expirationTime.nanos = nanos

        body.fileCreate.expirationTime = expirationTime

        return self
    }

    public func setProxyAccount(_ id: AccountId) -> Self {
        body.contractUpdateInstance.proxyAccountID = id.toProto()

        return self
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.contractService.createContract(tx)
    }
}
