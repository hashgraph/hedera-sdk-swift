import SwiftProtobuf
import Foundation

public class FileCreateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.fileCreate = Proto_FileCreateTransactionBody()

        // Warning: result of call is unused
        // method return `self` though
        _ = setExpirationTime(Int64(NSDate.init().timeIntervalSince1970) + 7898, 0)
    }

    public func setExpirationTime(_ seconds: Int64, _ nanos: Int32) -> Self {
        var expirationTime = Proto_Timestamp()
        expirationTime.seconds = seconds
        expirationTime.nanos = nanos

        body.fileCreate.expirationTime = expirationTime

        return self
    }

    public func addKey(_ key: Ed25519PublicKey) -> Self {
        body.fileCreate.keys.keys.append(key.toProto())

        return self
    }

    public func setContents(_ data: Data) -> Self {
        body.fileCreate.contents = data 

        return self
    }

    public func setContents(_ bytes: [UInt8]) -> Self {
        body.fileCreate.contents = Data(bytes) 

        return self
    }

    public func setContents(_ string: String) -> Self {
        body.fileCreate.contents = Data(Array(string.utf8))

        return self
    }

    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.fileService.createFile(tx)
    }
}
