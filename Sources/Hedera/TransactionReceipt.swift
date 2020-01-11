import SwiftProtobuf
import Foundation

public final class TransactionReceipt {
    let inner: Proto_TransactionReceipt

    public let status: UInt32

    init(_ proto: Proto_TransactionReceipt) {
        inner = proto

        status = UInt32(proto.status.rawValue)
    }

    public var accountId: AccountId {
        guard inner.hasAccountID else {
            fatalError("Receipt does not contain an AccountId")
        }

        return AccountId(inner.accountID)
    }

    public var fileId: FileId {
        guard inner.hasFileID else {
            fatalError("Receipt does not contain a FileId")
        }

        return FileId(inner.fileID)
    }

    public var contractId: ContractId {
        guard inner.hasContractID else {
            fatalError("Receipt does not contain a ContractId")
        }

        return ContractId(inner.contractID)
    }
}
