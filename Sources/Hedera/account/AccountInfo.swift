import Foundation

public struct AccountInfo {
    public let accountId: AccountId
    public let contractAccountId: String?
    public let isDeleted: Bool
    public let proxyAccountId: AccountId?
    public let proxyReceived: UInt64
    public let key: PublicKey
    public let balance: UInt64
    public let generateSendRecordThreshold: UInt64
    public let generateReceiveRecordThreshold: UInt64
    public let isReceiverSigRequired: Bool
    public let expirationTime: Date
    public let autoRenewPeriod: TimeInterval

    init(_ accountInfo: Proto_CryptoGetInfoResponse.AccountInfo) {
        let proxyAccountId: AccountId?
        if accountInfo.hasProxyAccountID {
            proxyAccountId = AccountId(accountInfo.proxyAccountID)
        } else {
            proxyAccountId = nil
        }

        accountId = AccountId(accountInfo.accountID)
        contractAccountId = accountInfo.contractAccountID.isEmpty ? nil : accountInfo.contractAccountID
        isDeleted = accountInfo.deleted
        self.proxyAccountId = proxyAccountId
        proxyReceived = UInt64(accountInfo.proxyReceived)
        key = PublicKey.fromProto(accountInfo.key)!
        balance = accountInfo.balance
        generateSendRecordThreshold = accountInfo.generateSendRecordThreshold
        generateReceiveRecordThreshold = accountInfo.generateReceiveRecordThreshold
        isReceiverSigRequired = accountInfo.receiverSigRequired
        expirationTime = Date(accountInfo.expirationTime)
        autoRenewPeriod = TimeInterval(accountInfo.autoRenewPeriod)!
    }
}
