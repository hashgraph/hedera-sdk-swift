import SwiftProtobuf
import Foundation
import Sodium

public class FileUpdateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.fileUpdate = Proto_FileUpdateTransactionBody()
    }

    @discardableResult
    public func setExpirationTime(_ date: Date) -> Self {
        body.fileUpdate.expirationTime = date.toProto()

        return self
    }

    @discardableResult
    public func setContents(_ data: Data) -> Self {
        body.fileUpdate.contents = data 

        return self
    }

    @discardableResult
    public func setContents(_ bytes: Bytes) -> Self {
        body.fileUpdate.contents = Data(bytes) 

        return self
    }

    @discardableResult
    public func setContents(_ string: String) -> Self {
        body.fileUpdate.contents = Data(Array(string.utf8))

        return self
    }

    @discardableResult
    public func setFile(_ id: FileId) -> Self {
        body.fileUpdate.fileID = id.toProto()

        return self
    }

    @discardableResult
    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.fileService.updateFile(tx)
    }
}
