import SwiftProtobuf
import Foundation
import Sodium

public class FileUpdateTransaction: TransactionBuilder {
    /// Create a FileUpdateTransaction
    ///
    /// This transaction must be signed with all the required keys to successfully update the file.
    public override init(client: Client? = nil) {
        super.init(client: client)

        body.fileUpdate = Proto_FileUpdateTransactionBody()
    }

    /// Set a new expiration time of the file
    @discardableResult
    public func setExpirationTime(_ date: Date) -> Self {
        body.fileUpdate.expirationTime = date.toProto()

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

    /// Set the file to be updated
    @discardableResult
    public func setFile(_ id: FileId) -> Self {
        body.fileUpdate.fileID = id.toProto()

        return self
    }
}
