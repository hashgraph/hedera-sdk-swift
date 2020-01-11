import SwiftProtobuf
import Foundation
import Sodium

public class FileContentsQuery: QueryBuilder<Bytes> {
    public override init() {
        super.init()

        body.fileGetContents = Proto_FileGetContentsQuery()
    }

    public func setFileId(_ id: FileId) -> Self {
        body.fileGetContents.fileID = id.toProto()

        return self
    }

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.fileGetContents.header)
    }

    override func mapResponse(_ response: Proto_Response) -> Bytes {
        guard case .fileGetContents(let response) = response.response else {
            fatalError("unreachable: response is not fileGetContents")
        }

        return Bytes(response.fileContents.contents)
    }
}
