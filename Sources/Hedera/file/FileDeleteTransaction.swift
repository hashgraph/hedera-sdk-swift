import SwiftProtobuf
import Foundation

public class FileDeleteTransaction: TransactionBuilder {
    /// Create a FileDeleteTransaction
    ///
    /// This transaction must be signed with all the required keys to successfully update the file.
    public override init(client: Client) {
        super.init(client: client)

        body.fileDelete = Proto_FileDeleteTransactionBody()
    }

    /// Set the file to delete
    @discardableResult
    public func setFile(_ id: FileId) -> Self {
        body.fileDelete.fileID = id.toProto()

        return self
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.fileService.deleteFile(tx)
    }
}
