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
    public override init(node: Node) {
        super.init(node: node)

        body.fileGetInfo = Proto_FileGetInfoQuery()
    }

    public func setFile(_ id: FileId) -> Self {
        body.fileGetInfo.fileID = id.toProto()

        return self
    }

    override func mapResponse(_ response: Proto_Response) -> Result<FileInfo, HederaError> {
        guard case .fileGetInfo(let response) = response.response else {
            return .failure(HederaError(message: "query response was not of type file info"))
        }

        return .success(FileInfo(response.fileInfo))
    }
}
