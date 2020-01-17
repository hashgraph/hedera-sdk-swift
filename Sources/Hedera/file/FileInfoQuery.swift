import NIO

public class FileInfoQuery: QueryBuilder<FileInfo> {
    public override init() {
        super.init()

        body.fileGetInfo = Proto_FileGetInfoQuery()
    }

    override func getCost(client: Client, node: Node) -> EventLoopFuture<Hbar> {
        super.getCost(client: client, node: node).map { cost in
            return max(cost, Hbar.fromTinybar(amount: 25))
        }
    }

    public func setFileId(_ id: FileId) -> Self {
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
