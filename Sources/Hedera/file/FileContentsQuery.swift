import SwiftProtobuf
import Foundation
import Sodium

public struct FileContents {
    let fileId: FileId
    let contents: Data

    init(_ contents: Proto_FileGetContentsResponse.FileContents) {
        fileId = FileId(contents.fileID)
        self.contents = contents.contents
    }
}

public class FileContentsQuery: QueryBuilder<FileContents> {
    public override init() {
        super.init()

        body.fileGetContents = Proto_FileGetContentsQuery()
    }

    public func setFile(_ id: FileId) -> Self {
        body.fileGetContents.fileID = id.toProto()

        return self
    }

    override func setHeader() {
        body.fileGetContents.header = header
    }

    override func mapResponse(_ response: Proto_Response) -> Result<FileContents, HederaError> {
        guard case .fileGetContents(let response) = response.response else {
            return .failure(HederaError.message("query response was not of type file contents"))
        }

        return .success(FileContents(response.fileContents))
    }

}
