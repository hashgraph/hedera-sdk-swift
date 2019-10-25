import SwiftProtobuf
import Foundation

public class AccountCreateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)

        var inner = Proto_CryptoCreateTransactionBody()
        // Required fixed autorenew duration (roughly 1/4 year)
        inner.autoRenewPeriod = TimeInterval(7_890_000).toProto()
        // Default to maximum values for record thresholds. Without this, records 
        // would be auto-created whenever a send or receive transaction takes place
        // for this new account. This should be an explicit ask.
        inner.sendRecordThreshold = UInt64.max
        inner.receiveRecordThreshold = UInt64.max

        body.cryptoCreateAccount = inner
    }

    public func setKey(_ key: Ed25519PublicKey) -> Self {
        body.cryptoCreateAccount.key = key.toProto()

        return self
    }

    public func setInitialBalance(_ balance: UInt64) -> Self {
        body.cryptoCreateAccount.initialBalance = balance

        return self
    }

    public func setProxyAccountId(_ id: AccountId) -> Self {
        body.cryptoCreateAccount.proxyAccountID = id.toProto()

        return self        
    }

    public func setSendRecordThreshold(_ threshold: UInt64) -> Self {
        body.cryptoCreateAccount.sendRecordThreshold = threshold
        
        return self
    }

    public func setReceiveRecordThreshold(_ threshold: UInt64) -> Self {
        body.cryptoCreateAccount.receiveRecordThreshold = threshold

        return self
    }
    
    public func setReceiverSignatureRequired(_ required: Bool) -> Self {
        body.cryptoCreateAccount.receiverSigRequired = required

        return self
    }

    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.cryptoCreateAccount.autoRenewPeriod = period.toProto()

        return self
    }
    
    override func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
        try grpc.cryptoService.createAccount(tx)
    }
}
