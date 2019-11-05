import SwiftProtobuf
import Foundation
import Sodium

public struct FileContents {
    let fileId: FileId;
    let contents: Data;
    
    init(_ contents: Proto_FileGetContentsResponse.FileContents) {
        fileId = FileId(contents.fileID)
        self.contents = contents.contents
    }
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

    override func mapResponse(_ response: Proto_Response) throws -> FileContents {
        guard case .fileGetContents(let response) = response.response else { throw HederaError(message: "query response was not of type file contents") }
        
        return FileContents(response.fileContents)
    }
}
