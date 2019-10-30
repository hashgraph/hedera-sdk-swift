import SwiftProtobuf
import Foundation

public struct TransactionId {
   let accountId: AccountId
   let transactionValidStart: Date

    public init(account id: AccountId) {
        accountId = id

        // Allow the transaction to be accepted as long as the
        // server is not more than 10 seconds behind us
        transactionValidStart = Date(timeIntervalSinceNow: -10)
    }
}

extension TransactionId: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "\(accountId)@\(transactionValidStart.wholeSecondsSince1970).\(transactionValidStart.nanosSinceSecondSince1970)"
    }

    public var debugDescription: String {
        description
    }
}

extension TransactionId: LosslessStringConvertible {
    public init?(_ description: String) {
        let atParts = description.split(separator: "@")
        guard atParts.count == 2 else { return nil }

        guard let id = EntityId(String(atParts[atParts.startIndex])) else { return nil }
        guard let start = Date(String(atParts[atParts.startIndex.advanced(by: 1)])) else { return nil }

        accountId = AccountId(id)
        transactionValidStart = start
    }
}

extension TransactionId: ProtoConvertible {
    typealias Proto = Proto_TransactionID

    func toProto() -> Proto {
        var proto = Proto()
        proto.accountID = accountId.toProto()
        proto.transactionValidStart = transactionValidStart.toProto()

        return proto
    }

    init?(_ proto: Proto) {
        guard proto.hasTransactionValidStart && proto.hasAccountID else { return nil }

        accountId = AccountId(proto.accountID)
        transactionValidStart = Date(proto.transactionValidStart)
    }
}
