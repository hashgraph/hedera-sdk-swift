import Foundation
import HederaCrypto
import GRPC
import HederaProtoServices
import NIO

var DEFAULT_AUTO_RENEW_PERIOD: Double = 7776000

extension Key {
    func fromProtobuf(_ key: Proto_Key) -> Key? {
        switch key.key {
        case .ed25519:
            return PublicKey.fromBytes(bytes: key.ed25519.bytes)
        case .keyList:
            return KeyList(key.keyList)
        case .contractID:
            return ContractId(key.contractID)
        case .thresholdKey:
            return KeyList(key.thresholdKey.keys,thresholdKey: key.thresholdKey.threshold)
        case .rsa3072, .ecdsa384, .none:
            return nil
        }
    }
}

extension KeyList {
    func fromProtobuf(_ proto: Proto_Key) -> Key {
        var list = KeyList()
        guard proto.keyList.keys.count > 0 else { return nil }
        list.keys = proto.keyList.keys.compactMap(proto.keyList.keys)

        // Don't want to silently throw away keys we don't recognize
        guard proto.keyList.keys.count == keys.count else { return nil }


        super.init()
    }

    func fromProtobuf(_ proto: Proto_KeyList, thresholdKey: UInt32) -> Key {
        var list = KeyList()
        guard proto.keys.count > 0 else { return nil }
        keys = proto.keys.compactMap(Key.fromProtobufKey)
        self.threshold = thresholdKey

        // Don't want to silently throw away keys we don't recognize
        guard proto.keys.count == keys.count else { return nil }
    }
}



init?(_ proto: Proto_KeyList, thresholdKey: UInt32) {
    guard proto.keys.count > 0 else { return nil }
    keys = proto.keys.compactMap(Key.fromProtobufKey)
    self.threshold = thresholdKey

    // Don't want to silently throw away keys we don't recognize
    guard proto.keys.count == keys.count else { return nil }
    super.init()
}

class AccountCreateTransaction: Transaction {
    var proxyAccountId: AccountId? = nil
    var key: Key? = nil
    var accountMemo: String = ""
    var initialBalance: Hbar = Hbar(0)
    var receiversSigRequired = false
    var autoRenewPeriod: TimeInterval = DEFAULT_AUTO_RENEW_PERIOD

    @discardableResult
    public func setProxyAccountId(_ accountId: AccountId) -> Self {
        proxyAccountId = accountId
        return self
    }

    @discardableResult
    public func setKey(_ key: Key) -> Self {
        self.key = key
        return self
    }

    @discardableResult
    public func setInitialBalance(_ balance: Hbar) -> Self {
        initialBalance = balance
        return self
    }

    @discardableResult
    public func setReceiverSignatureRequired(_ require: Bool) -> Self {
        receiversSigRequired = require
        return self
    }

    @discardableResult
    public func setAutoRenewPeriod(_ time: TimeInterval) -> Self {
        autoRenewPeriod = time
        return self
    }

    @discardableResult
    public func setAccountMemo(_ memo: String) -> Self {
        accountMemo = memo
        return self
    }

    convenience init(_ proto: Proto_TransactionBody) {
        self.init()

        setProxyAccountId(AccountId(proto.cryptoCreateAccount.proxyAccountID))
        setKey(Key.fromProtobufKey(proto.cryptoCreateAccount.key))
        setAccountMemo(proto.cryptoCreateAccount.memo)
        setAutoRenewPeriod(TimeInterval(proto.cryptoCreateAccount.autoRenewPeriod.seconds))
        setInitialBalance(Hbar.fromTinybars(proto.cryptoCreateAccount.initialBalance))
        setReceiverSignatureRequired(proto.cryptoCreateAccount.receiverSigRequired)
    }

    override func executeAsync(_ index: Int) -> UnaryCall<Proto_Transaction, Proto_TransactionResponse> {
        nodes[circular: index].getCrypto().createAccount(try! makeRequest(index))
    }

    func build() -> Proto_CryptoCreateTransactionBody {
        var body = Proto_CryptoCreateTransactionBody()
        body.memo = accountMemo
        body.initialBalance = initialBalance.toTinybars()
        body.receiverSigRequired = receiversSigRequired
        body.autoRenewPeriod = autoRenewPeriod.toProtobuf()

        if proxyAccountId != nil {
            body.proxyAccountID = proxyAccountId!.toProtobuf()
        }

        var k: PrivateKey
        if key != nil {
            body.key = k.toProtobuf()
        }

        return body
    }

    override func onFreeze(_ transactionBody: inout Proto_TransactionBody) {
        transactionBody.cryptoCreateAccount = build()
    }
}
