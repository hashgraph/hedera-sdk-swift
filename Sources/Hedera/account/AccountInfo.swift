import Foundation

public struct AccountInfo {
    public let accountId: AccountId
    public let contractAccountId: String?
    public let isDeleted: Bool
    public let proxyAccountId: AccountId?
    public let proxyReceived: Hbar
    public let key: PublicKey
    public let balance: Hbar
    public let generateSendRecordThreshold: Hbar
    public let generateReceiveRecordThreshold: Hbar
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
        proxyReceived = Hbar.fromTinybar(amount: accountInfo.proxyReceived)
        key = PublicKey.fromProto(accountInfo.key)!
        balance = Hbar.fromTinybar(amount: Int64(accountInfo.balance))
        generateSendRecordThreshold = Hbar.fromTinybar(amount: Int64(accountInfo.generateSendRecordThreshold))
        generateReceiveRecordThreshold = Hbar.fromTinybar(amount: Int64(accountInfo.generateReceiveRecordThreshold))
        isReceiverSigRequired = accountInfo.receiverSigRequired
        expirationTime = Date(accountInfo.expirationTime)
        autoRenewPeriod = TimeInterval(accountInfo.autoRenewPeriod)!
    }
}
