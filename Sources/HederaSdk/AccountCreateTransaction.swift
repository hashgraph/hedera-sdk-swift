import Foundation
import HederaCrypto
import GRPC
import HederaProtoServices
import NIO

var DEFAULT_AUTO_RENEW_PERIOD: Double = 7776000

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
        setKey(Key.fromProtobuf(proto.cryptoCreateAccount.key)!)
        setAccountMemo(proto.cryptoCreateAccount.memo)
        setAutoRenewPeriod(TimeInterval(proto.cryptoCreateAccount.autoRenewPeriod.seconds))
        setInitialBalance(Hbar.fromTinybars(proto.cryptoCreateAccount.initialBalance))
        setReceiverSignatureRequired(proto.cryptoCreateAccount.receiverSigRequired)
    }

    override func executeAsync(_ index: Int, save: Bool? = true) -> UnaryCall<Proto_Transaction, Proto_TransactionResponse> {
        nodes[circular: index].getCrypto().createAccount(try! makeRequest(index, save: save))
    }

    func build() -> Proto_CryptoCreateTransactionBody {
        var body = Proto_CryptoCreateTransactionBody()
        body.memo = accountMemo
        body.initialBalance = UInt64(initialBalance.toTinybars())
        body.receiverSigRequired = receiversSigRequired
        body.autoRenewPeriod = autoRenewPeriod.toProtobuf()

        if proxyAccountId != nil {
            body.proxyAccountID = proxyAccountId!.toProtobuf()
        }

        if key != nil {
            body.key = key!.toProtobufKey()!
        }

        return body
    }

    override func onFreeze(_ transactionBody: inout Proto_TransactionBody) {
        transactionBody.cryptoCreateAccount = build()
    }
}
