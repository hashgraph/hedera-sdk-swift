import SwiftProtobuf
import Foundation
import NIO

public struct TransactionId {
    public let accountId: AccountId
    public let validStart: Date

    public init(account id: AccountId) {
        accountId = id

        // Allow the transaction to be accepted as long as the
        // server is not more than 10 seconds behind us
        validStart = Date(timeIntervalSinceNow: -10)
    }

    public init(account id: AccountId, validStart: Date) {
        accountId = id
        self.validStart = validStart
    }
}

extension TransactionId: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "\(accountId)@\(validStart.wholeSecondsSince1970).\(validStart.nanosSinceSecondSince1970)"
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
        validStart = start
    }
}

extension TransactionId: ProtoConvertible {
    typealias Proto = Proto_TransactionID

    func toProto() -> Proto {
        var proto = Proto()
        proto.accountID = accountId.toProto()
        proto.transactionValidStart = validStart.toProto()

        return proto
    }

    init?(_ proto: Proto) {
        guard proto.hasTransactionValidStart && proto.hasAccountID else { return nil }

        accountId = AccountId(proto.accountID)
        validStart = Date(proto.transactionValidStart)
    }
}

extension TransactionId {
    public func getReceipt(client: Client) -> EventLoopFuture<TransactionReceipt> {
        TransactionReceiptQuery().setTransactionId(self).execute(client: client)
    }

    public func getRecord(client: Client) -> EventLoopFuture<TransactionRecord> {
        TransactionRecordQuery().setTransactionId(self).execute(client: client)
    }
}