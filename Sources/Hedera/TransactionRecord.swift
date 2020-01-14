import Sodium
import Foundation

public struct TransactionRecord {
    public let transactionId: TransactionId
    public let transactionHash: Bytes
    public let transactionFee: Hbar
    public let consensusTimestamp: Date?
    public let transactionMemo: String?
    public let receipt: TransactionReceipt
    public let transfers: [Transfer]
    // let contractResult: ContractResultType?

    init(_ proto: Proto_TransactionRecord) {
        guard proto.hasReceipt else {
            fatalError("unreachable: transaction record has no receipt")
        }

        transactionId = TransactionId(proto.transactionID)!
        transactionHash = Bytes(proto.transactionHash)
        transactionFee = Hbar.fromTinybar(amount: Int64(proto.transactionFee))
        consensusTimestamp = proto.hasConsensusTimestamp ? Date(proto.consensusTimestamp): nil
        transactionMemo = proto.memo.isEmpty ? nil : proto.memo
        receipt = TransactionReceipt(proto.receipt)
        transfers = proto.transferList.accountAmounts.map { Transfer($0) }
        // self.contractResult = ContractResultType(proto.body)
    }
}

public struct Transfer {
    public let accountId: AccountId
    public let amount: Hbar

    init(_ proto: Proto_AccountAmount) {
        accountId = AccountId(proto.accountID)
        amount = Hbar.fromTinybar(amount: proto.amount)
    }
}
