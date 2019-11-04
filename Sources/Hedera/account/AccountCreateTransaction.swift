import Foundation

public final class AccountCreateTransaction: TransactionBuilder {
    public override init(client: Client? = nil) {
        super.init(client: client)

        var inner = Proto_CryptoCreateTransactionBody()
        // Required fixed autorenew duration (roughly 1/4 year)
        inner.autoRenewPeriod = TimeInterval(7_890_000).toProto()
        // Default to maximum values for record thresholds. Without this, records 
        // would be auto-created whenever a send or receive transaction takes place
        // for this new account. This should be an explicit ask.
        inner.sendRecordThreshold = UInt64(Int64.max)
        inner.receiveRecordThreshold = UInt64(Int64.max)

        body.cryptoCreateAccount = inner
    }
    
    @discardableResult
    override public func setTransactionId(_ id: TransactionId) -> Self {
        // Setting the transaction ID defaults the shard and realm IDs
        // If you truly want to create a _new_ realm, then you need
        // to null the realm after setting this

        if (!body.cryptoCreateAccount.hasShardID) {
            setShardId(id.accountId.id.shard);
        }

        if (!body.cryptoCreateAccount.hasRealmID) {
            setRealmId(id.accountId.id.realm);
        }

        return super.setTransactionId(id) as! Self
    }

    @discardableResult
    public func setKey(_ key: Ed25519PublicKey) -> Self {
        body.cryptoCreateAccount.key = key.toProto()

        return self
    }

    @discardableResult
    public func setInitialBalance(_ balance: UInt64) -> Self {
        body.cryptoCreateAccount.initialBalance = balance

        return self
    }

    @discardableResult
    public func setProxyAccountId(_ id: AccountId) -> Self {
        body.cryptoCreateAccount.proxyAccountID = id.toProto()

        return self        
    }

    @discardableResult
    public func setSendRecordThreshold(_ threshold: UInt64) -> Self {
        body.cryptoCreateAccount.sendRecordThreshold = threshold
        
        return self
    }

    @discardableResult
    public func setReceiveRecordThreshold(_ threshold: UInt64) -> Self {
        body.cryptoCreateAccount.receiveRecordThreshold = threshold

        return self
    }
    
    @discardableResult
    public func setReceiverSignatureRequired(_ required: Bool) -> Self {
        body.cryptoCreateAccount.receiverSigRequired = required

        return self
    }

    @discardableResult
    public func setAutoRenewPeriod(_ period: TimeInterval) -> Self {
        body.cryptoCreateAccount.autoRenewPeriod = period.toProto()

        return self
    }
    
    @discardableResult
    public func setShardId(_ id: UInt64) -> Self {
        var shard = Proto_ShardID()
        shard.shardNum = Int64(id)
        body.cryptoCreateAccount.shardID = shard
        
        return self
    }
    
    @discardableResult
    public func setRealmId(_ id: UInt64) -> Self {
        var realm = Proto_RealmID()
        realm.realmNum = Int64(id)
        body.cryptoCreateAccount.realmID = realm
        
        return self
    }
}
