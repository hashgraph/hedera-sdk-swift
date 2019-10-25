import SwiftProtobuf
import Foundation

public class FileDeleteTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.fileDelete = Proto_FileDeleteTransactionBody()
    }

    public func setFileId(_ id: FileId) -> Self {
        body.fileDelete.fileID = id.toProto()

        return self
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.fileService.deleteFile(tx)
    }
}
