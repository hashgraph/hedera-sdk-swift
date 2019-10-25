import SwiftProtobuf
import Foundation
import Sodium

public struct FileInfo {
    let fileId: FileId;
    let size: UInt64;
    let expirationTime: Date;
    let deleted: Bool;
    // TODO:
    // let keys: Ed25519PublicKey[];
}

public class FileInfoQuery: QueryBuilder<FileInfo> {
    public override init(client: Client) {
        super.init(client: client)

        body.fileGetInfo = Proto_FileGetInfoQuery()
    }

    public func setFile(_ id: FileId) -> Self {
        body.fileGetInfo.fileID = id.toProto()

        return self
    }

    override func executeClosure(
        _ grpc: HederaGRPCClient
    ) throws -> Proto_Response {
        body.fileGetInfo.header = header
        throw HederaError(message: "\(body.fileGetInfo.header.payment)")
        return try grpc.fileService.getFileInfo(body)
    }

    func mapResponse(response: Proto_Response) -> FileInfo {
        let fileInfo = response.fileGetInfo.fileInfo
        let fileId = fileInfo.fileID

        return FileInfo(
            fileId: EntityId(
                shard: UInt64(fileId.shardNum), 
                realm: UInt64(fileId.realmNum),
                num: UInt64(fileId.fileNum)
            ),
            size: UInt64(fileInfo.size),
            expirationTime: Date(fileInfo.expirationTime),
            deleted: fileInfo.deleted
        )
    }
}
