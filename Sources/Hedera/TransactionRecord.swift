import Sodium
import Foundation

public struct TransactionRecord {
    let receipt: TransactionReceipt?
    let transactionHash: Data
    let consensusTimestamp: Date
    let transactionId: TransactionId
    let memo: String
    let transactionFee: UInt64
    // let contractResult: ContractResultType?
    let transferList: [AccountAmount]

    init(_ proto: Proto_TransactionRecord) {
        self.receipt = proto.hasReceipt ? TransactionReceipt(proto.receipt) : nil
        self.transactionHash = proto.transactionHash
        self.consensusTimestamp = Date(proto.consensusTimestamp)
        self.transactionId = TransactionId(proto.transactionID)!
        self.memo = proto.memo
        self.transactionFee = UInt64(proto.transactionFee)
        // self.contractResult = ContractResultType(proto.body)
        self.transferList = proto.transferList.accountAmounts.map { AccountAmount($0) }
    }
}

public struct AccountAmount {
    let accountId: AccountId
    let amount: UInt64

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
