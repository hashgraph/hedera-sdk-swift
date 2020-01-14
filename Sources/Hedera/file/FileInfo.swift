import Foundation

public struct FileInfo {
    public let fileId: FileId
    public let size: UInt64
    public let expirationTime: Date
    public let isDeleted: Bool
    public let keys: [PublicKey]

    init(_ info: Proto_FileGetInfoResponse.FileInfo) {
        fileId = FileId(info.fileID)
        size = UInt64(info.size)
        expirationTime = Date(info.expirationTime)
        isDeleted = info.deleted
        keys = KeyList(info.keys)!.keys
    }
}