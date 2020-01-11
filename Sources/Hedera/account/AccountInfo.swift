import Foundation

public struct AccountInfo {
    let accountId: AccountId
    let contractAccountId: String?
    let isDeleted: Bool
    let proxyAccountId: AccountId?
    let proxyReceived: UInt64
    let key: PublicKey
    let balance: UInt64
    let generateSendRecordThreshold: UInt64
    let generateReceiveRecordThreshold: UInt64
    let isReceiverSigRequired: Bool
    let expirationTime: Date
    let autoRenewPeriod: TimeInterval

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
