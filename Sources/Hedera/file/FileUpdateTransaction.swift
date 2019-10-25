import SwiftProtobuf
import Foundation

public class FileUpdateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.fileUpdate = Proto_FileUpdateTransactionBody()
    }

    public func setExpirationTime(_ seconds: Int64, _ nanos: Int32) -> Self {
        var expirationTime = Proto_Timestamp()
        expirationTime.seconds = seconds
        expirationTime.nanos = nanos

        body.fileUpdate.expirationTime = expirationTime

        return self
    }

    public func setContents(_ data: Data) -> Self {
        body.fileUpdate.contents = data 

        return self
    }

    public func setContents(_ bytes: [UInt8]) -> Self {
        body.fileUpdate.contents = Data(bytes) 

        return self
    }

    public func setContents(_ string: String) -> Self {
        body.fileUpdate.contents = Data(Array(string.utf8))

        return self
    }

    public func setFileId(_ id: FileId) -> Self {
        body.fileUpdate.fileID = id.toProto()

        return self
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.fileService.updateFile(tx)
    }
}
