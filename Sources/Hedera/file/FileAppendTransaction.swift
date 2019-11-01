import SwiftProtobuf
import Foundation
import Sodium

public class FileAppendTransaction: TransactionBuilder {
    /// Create a FileAppendTransaction
    ///
    /// This transaction must be signed with all the required keys to successfully update the file.
    public override init(client: Client? = nil) {
        super.init(client: client)

        body.fileAppend = Proto_FileAppendTransactionBody()
    }

    /// Set the content to be appened to the file
    @discardableResult
    public func setContents(_ data: Data) -> Self {
        body.fileAppend.contents = data 

        return self
    }

    /// Set the content to be appened to the file
    @discardableResult
    public func setContents(_ bytes: Bytes) -> Self {
        body.fileAppend.contents = Data(bytes) 

        return self
    }

    /// Set the content to be appened to the file
    @discardableResult
    public func setContents(_ string: String) -> Self {
        body.fileAppend.contents = Data(Array(string.utf8))

        return self
    }

    /// Set the file to be append the contents to
    @discardableResult
    public func setFile(_ id: FileId) -> Self {
        body.fileAppend.fileID = id.toProto()

        return self
    }

//    override static func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
//        try grpc.fileService.appendContent(tx)
//    }
}
