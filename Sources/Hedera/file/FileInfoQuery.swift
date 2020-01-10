import SwiftProtobuf
import Foundation
import Sodium

public struct FileInfo {
    let fileId: FileId
    let size: UInt64
    let expirationTime: Date
    let deleted: Bool
    let keys: KeyList

    init(_ info: Proto_FileGetInfoResponse.FileInfo) {
        fileId = FileId(info.fileID)
        size = UInt64(info.size)
        expirationTime = Date(info.expirationTime)
        deleted = info.deleted
        keys = KeyList(info.keys)!
    }
}

public class FileInfoQuery: QueryBuilder<FileInfo> {
    public override init() {
        super.init()

        body.fileGetInfo = Proto_FileGetInfoQuery()
    }

    public func setFile(_ id: FileId) -> Self {
        body.fileGetInfo.fileID = id.toProto()

        return self
    }

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.fileGetInfo.header)
    }

    override func mapResponse(_ response: Proto_Response) -> FileInfo {
        guard case .fileGetInfo(let response) = response.response else {
            fatalError("unreachable: response is not fileGetInfo")
        }

        return FileInfo(response.fileInfo)
    }
}
