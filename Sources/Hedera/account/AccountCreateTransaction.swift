import Foundation

public final class AccountCreateTransaction: TransactionBuilder {
    public override init() {
        super.init()
        body.cryptoCreateAccount = Proto_CryptoCreateTransactionBody()

        // Required fixed autorenew duration (roughly 1/4 year)
        setAutoRenewPeriod(TimeInterval(7_890_000))
        // Default to maximum values for record thresholds. Without this, records 
        // would be auto-created whenever a send or receive transaction takes place
        // for this new account. This should be an explicit ask.
        setSendRecordThreshold(Hbar.MAX)
        setReceiveRecordThreshold(Hbar.MAX)

    }

    @discardableResult
    public func setKey(_ key: PublicKey) -> Self {
        body.cryptoCreateAccount.key = key.toProto()

        return self
    }

    @discardableResult
    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.cryptoCreateAccount.autoRenewPeriod = period.toProto()

        return self
    }

    @discardableResult
    public func setInitialBalance(_ balance: Hbar) -> Self {
        body.cryptoCreateAccount.initialBalance = UInt64(balance.asTinybar())

        return self
    }

    @discardableResult
    public func setReceiveRecordThreshold(_ threshold: Hbar) -> Self {
        body.cryptoCreateAccount.receiveRecordThreshold = UInt64(threshold.asTinybar())

        return self
    }

    @discardableResult
    public func setSendRecordThreshold(_ threshold: Hbar) -> Self {
        body.cryptoCreateAccount.sendRecordThreshold = UInt64(threshold.asTinybar())

        return self
    }

    @discardableResult
    public func setProxyAccountId(_ id: AccountId) -> Self {
        body.cryptoCreateAccount.proxyAccountID = id.toProto()

        return self
    }

    @discardableResult
    public func setReceiverSignatureRequired(_ required: Bool) -> Self {
        body.cryptoCreateAccount.receiverSigRequired = required

        return self
    }
}
