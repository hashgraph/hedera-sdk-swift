import SwiftProtobuf
import Foundation
import Sodium

public class FileUpdateTransaction: TransactionBuilder {
    /// Create a FileUpdateTransaction
    ///
    /// This transaction must be signed with all the required keys to successfully update the file.
    public override init() {
        super.init()

        body.fileUpdate = Proto_FileUpdateTransactionBody()
    }

    /// Set the file to be updated
    @discardableResult
    public func setFileId(_ id: FileId) -> Self {
        body.fileUpdate.fileID = id.toProto()

        return self
    }

    /// Set a new expiration time of the file
    @discardableResult
    public func setExpirationTime(_ date: Date) -> Self {
        body.fileUpdate.expirationTime = date.toProto()

        return self
    }

    /// Add a key to the new list of keys for this file
    @discardableResult
    public func addKey(_ key: PublicKey) -> Self {
        if !body.fileUpdate.hasKeys {
            body.fileUpdate.keys = Proto_KeyList()
        }

        body.fileUpdate.keys.keys.append(key.toProto())

        return self
    }

    /// Set the new contents of the file
    @discardableResult
    public func setContents(_ data: Data) -> Self {
        body.fileUpdate.contents = data

        return self
    }

    /// Set the new contents of the file
    @discardableResult
    public func setContents(_ bytes: Bytes) -> Self {
        body.fileUpdate.contents = Data(bytes)

        return self
    }

    /// Set the new contents of the file
    @discardableResult
    public func setContents(_ string: String) -> Self {
        body.fileUpdate.contents = Data(Array(string.utf8))

        return self
    }
}
