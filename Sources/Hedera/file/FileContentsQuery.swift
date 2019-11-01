import SwiftProtobuf
import Foundation
import Sodium

public struct FileContents {
    let fileId: FileId;
    let contents: Data;
}

public class FileContentsQuery: QueryBuilder<FileContents> {
    public override init(client: Client) {
        super.init(client: client)

        body.fileGetContents = Proto_FileGetContentsQuery()
    }

    public func setFile(_ id: FileId) -> Self {
        body.fileGetContents.fileID = id.toProto()

        return self
    }

    override func executeClosure(
        _ grpc: HederaGRPCClient
    ) throws -> Proto_Response {
        body.fileGetContents.header = header
        return try grpc.fileService.getFileContent(body)
    }

    override func mapResponse(_ response: Proto_Response) -> FileContents {
        let fileContents = response.fileGetContents.fileContents

        return FileContents(
            fileId: FileId(fileContents.fileID),
            contents: fileContents.contents
        )
    }
}
