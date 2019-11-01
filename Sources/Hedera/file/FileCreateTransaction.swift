import SwiftProtobuf
import Foundation
import Sodium

public class FileCreateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        body.fileCreate = Proto_FileCreateTransactionBody()

        // For files and contracts expiration time needs be set to now + 7898 seconds
        // otherwise file/contract creation fails
        setExpirationTime(Date(timeIntervalSinceNow: 7898))
    }

    /// Set the expiration time of the file
    @discardableResult
    public func setExpirationTime(_ date: Date) -> Self {
        body.fileCreate.expirationTime = date.toProto()

        return self
    }

    /// Add a Ed25519PublicKey that will be required to create and update this file
    /// 
    /// At least one key must be provided
    @discardableResult
    public func addKey(_ key: Ed25519PublicKey) -> Self {
        body.fileCreate.keys.keys.append(key.toProto())

        return self
    }

    /// Set the initial contents of the to be created file
    @discardableResult
    public func setContents(_ data: Data) -> Self {
        body.fileCreate.contents = data 

        return self
    }

    /// Set the initial contents of the to be created file
    @discardableResult
    public func setContents(_ bytes: Bytes) -> Self {
        body.fileCreate.contents = Data(bytes) 

        return self
    }

    /// Set the initial contents of the to be created file
    @discardableResult
    public func setContents(_ string: String) -> Self {
        body.fileCreate.contents = Data(Array(string.utf8))

        return self
    }

//    override static func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
//        try grpc.fileService.createFile(tx)
//    }
}
