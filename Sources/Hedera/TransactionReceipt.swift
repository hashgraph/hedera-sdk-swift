import SwiftProtobuf
import Foundation

public final class TransactionReceipt {
    public let status: UInt32
    public let accountId: AccountId?
    public let fileId: FileId?
    public let contractId: ContractId?
    public let exchangeRateSet: ExchangeRateSet?

    init(_ proto: Proto_TransactionReceipt) {
        self.status = UInt32(proto.status.rawValue)
        self.accountId = proto.hasAccountID ? AccountId(proto.accountID) : nil
        self.fileId = proto.hasFileID ? FileId(proto.fileID) : nil
        self.contractId = proto.hasContractID ? ContractId(proto.contractID) : nil
        self.exchangeRateSet = proto.hasExchangeRate ? ExchangeRateSet(proto.exchangeRate) : nil
    }
}
