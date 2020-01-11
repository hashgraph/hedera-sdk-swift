import SwiftProtobuf
import Foundation

public struct ContractInfo {
    public let contractId: ContractId
    public let accountId: AccountId
    public let contractAccountId: String
    public let adminKey: PublicKey?
    public let expirationTime: Date
    public let autoRenewPeriod: TimeInterval
    public let storage: UInt64
    public let contractMemo: String?

    init(_ contractInfo: Proto_ContractGetInfoResponse.ContractInfo) {
        contractId = ContractId(contractInfo.contractID)
        accountId = AccountId(contractInfo.accountID)
        contractAccountId = contractInfo.contractAccountID
        adminKey = PublicKey.fromProto(contractInfo.adminKey)
        expirationTime = Date(contractInfo.expirationTime)
        autoRenewPeriod = TimeInterval(contractInfo.autoRenewPeriod)!
        storage = UInt64(contractInfo.storage)
        contractMemo = contractInfo.memo.isEmpty ? nil : contractInfo.memo
    }
}