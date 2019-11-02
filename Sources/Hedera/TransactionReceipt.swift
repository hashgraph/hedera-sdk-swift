import SwiftProtobuf
import Foundation

public final class TransactionReceipt {
    let status: UInt32
    let accountId: AccountId?
    let fileId: FileId?
    let contractId: ContractId?
    let exchangeRateSet: ExchangeRateSet?

    init(_ proto: Proto_TransactionReceipt) {
        self.status = UInt32(proto.status.rawValue)
        self.accountId = proto.hasAccountID ? AccountId(proto.accountID) : nil
        self.fileId = proto.hasFileID ? FileId(proto.fileID) : nil
        self.contractId = proto.hasContractID ? ContractId(proto.contractID) : nil
        self.exchangeRateSet = proto.hasExchangeRate ? ExchangeRateSet(proto.exchangeRate) : nil
    }
}
