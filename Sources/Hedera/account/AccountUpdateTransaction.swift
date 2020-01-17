import SwiftProtobuf
import Foundation

public final class AccountUpdateTransaction: TransactionBuilder {
    public override init() {
        super.init()
        body.cryptoUpdateAccount = Proto_CryptoUpdateTransactionBody()
    }

    @discardableResult
    public func setAccountId(_ id: AccountId) -> Self {
        body.cryptoUpdateAccount.accountIdtoUpdate = id.toProto()
        return self
    }

    @discardableResult
    public func setKey(_ key: PublicKey) -> Self {
        body.cryptoUpdateAccount.key = key.toProto()
        return self
    }

    @discardableResult
    public func setAutoRenewPeriod(_ duration: TimeInterval) -> Self {
        body.cryptoUpdateAccount.autoRenewPeriod = duration.toProto()
        return self
    }

    @discardableResult
    public func setReceiveRecordThreshold(_ threshold: Hbar) -> Self {
        body.cryptoUpdateAccount.receiveRecordThresholdWrapper = Google_Protobuf_UInt64Value(UInt64(threshold.asTinybar()))
        return self
    }

    @discardableResult
    public func setSendRecordThreshold(_ threshold: Hbar) -> Self {
        body.cryptoUpdateAccount.sendRecordThresholdWrapper = Google_Protobuf_UInt64Value(UInt64(threshold.asTinybar()))
        return self
    }

    @discardableResult
    public func setExpirationTime(_ date: Date) -> Self {
        body.cryptoUpdateAccount.expirationTime = date.toProto()
        return self
    }

    @discardableResult
    public func setProxyAccountId(_ id: AccountId) -> Self {
        body.cryptoUpdateAccount.proxyAccountID = id.toProto()
        return self
    }

    @discardableResult
    public func setReceiverSignatureRequired(_ required: Bool) -> Self {
        body.cryptoUpdateAccount.receiverSigRequiredWrapper = Google_Protobuf_BoolValue(required)
        return self
    }
}
