import SwiftProtobuf
import Foundation

public final class AccountUpdateTransaction: TransactionBuilder {
    public override init(client: Client) {
        super.init(client: client)
        body.cryptoUpdateAccount = Proto_CryptoUpdateTransactionBody()
    }
    
    @discardableResult
    public func setAccountForUpdate(_ id: AccountId) -> Self {
        body.cryptoUpdateAccount.accountIdtoUpdate = id.toProto()
        return self
    }
    
    @discardableResult
    public func setKey(_ key: Ed25519PublicKey) -> Self {
        body.cryptoUpdateAccount.key = key.toProto()
        return self
    }
    
    @discardableResult
    public func setProxyAccount(_ id: AccountId) -> Self {
        body.cryptoUpdateAccount.proxyAccountID = id.toProto()
        return self
    }
    
    @discardableResult
    public func setSendRecordThreshold(_ threshold: UInt64) -> Self {
        body.cryptoUpdateAccount.sendRecordThresholdWrapper = Google_Protobuf_UInt64Value(threshold)
        return self
    }
    
    @discardableResult
    public func setReceiveRecordThreshold(_ threshold: UInt64) -> Self {
        body.cryptoUpdateAccount.receiveRecordThresholdWrapper = Google_Protobuf_UInt64Value(threshold)
        return self
    }
    
    @discardableResult
    public func setAutoRenewPeriod(_ duration: TimeInterval) -> Self {
        body.cryptoUpdateAccount.autoRenewPeriod = duration.toProto()
        return self
    }
    
    @discardableResult
    public func setExpirationTime(_ date: Date) -> Self {
        body.cryptoUpdateAccount.expirationTime = date.toProto()
        return self
    }
    
    @discardableResult
    public func setReceiverSignatureRequired(_ required: Bool) -> Self {
        body.cryptoUpdateAccount.receiverSigRequiredWrapper = Google_Protobuf_BoolValue(required)
        return self
    }
    
//    override static func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
//        try grpc.cryptoService.updateAccount(tx)
//    }
}
