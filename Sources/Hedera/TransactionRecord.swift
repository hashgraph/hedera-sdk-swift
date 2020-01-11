import Sodium
import Foundation

public struct TransactionRecord {
    public let transactionId: TransactionId
    public let transactionHash: Bytes
    public let transactionFee: UInt64
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
        transactionFee = UInt64(proto.transactionFee)
        consensusTimestamp = proto.hasConsensusTimestamp ? Date(proto.consensusTimestamp): nil
        transactionMemo = proto.memo.isEmpty ? nil : proto.memo
        receipt = TransactionReceipt(proto.receipt)
        transfers = proto.transferList.accountAmounts.map { Transfer($0) }
        // self.contractResult = ContractResultType(proto.body)
    }
}

public struct Transfer {
    public let accountId: AccountId
    public let amount: UInt64

    init(_ proto: Proto_AccountAmount) {
        accountId = AccountId(proto.accountID)
        amount = UInt64(proto.amount)
    }
}

// public enum ContractResultType {
//     case call(FunctionResult)
//     case create(FunctionResult)

//     init?(_ body: Proto_TransactionRecord.OneOf_Body?) {
//         if let body = body {
//             switch body {
//             case .contractCallResult(let result):
//                 self = ContractResultType.call(FunctionResult(result))
//             case .contractCreateResult(let result):
//                 self = ContractResultType.create(FunctionResult(result))
//             }
//         } else {
//             return nil
//         }
//     }
// }
