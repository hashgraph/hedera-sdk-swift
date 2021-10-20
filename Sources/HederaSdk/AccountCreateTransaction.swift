import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

let DEFAULT_AUTO_RENEW_PERIOD: Double = 7_776_000

public final class AccountCreateTransaction: Transaction {
  var proxyAccountId: AccountId?
  var key: Key?
  var accountMemo: String?
  var initialBalance: Hbar?
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

  public func getProxyAccountId() -> AccountId? {
    proxyAccountId
  }

  public func getKey() -> Key? {
    key
  }

  public func getInitialBalance() -> Hbar? {
    initialBalance
  }

  public func getReceiverSignatureRequired() -> Bool {
    receiversSigRequired
  }

  public func getAutoRenewPeriod() -> TimeInterval {
    autoRenewPeriod
  }

  public func getAccountMemo() -> String? {
    accountMemo
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setProxyAccountId(AccountId(proto.cryptoCreateAccount.proxyAccountID))
    setKey(Key.fromProtobuf(proto.cryptoCreateAccount.key)!)
    setAccountMemo(proto.cryptoCreateAccount.memo)
    setAutoRenewPeriod(TimeInterval(proto.cryptoCreateAccount.autoRenewPeriod.seconds))
    setInitialBalance(Hbar.fromTinybars(Int64(proto.cryptoCreateAccount.initialBalance)))
    setReceiverSignatureRequired(proto.cryptoCreateAccount.receiverSigRequired)
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getCrypto().createAccount
  }

  func build() -> Proto_CryptoCreateTransactionBody {
    var body = Proto_CryptoCreateTransactionBody()
    body.receiverSigRequired = receiversSigRequired
    body.autoRenewPeriod = autoRenewPeriod.toProtobuf()

    if let accountMemo = accountMemo {
      body.memo = accountMemo
    }

    if let initialBalance = initialBalance {
      body.initialBalance = UInt64(initialBalance.toProtobuf())
    }

    if let proxyAccountId = proxyAccountId {
      body.proxyAccountID = proxyAccountId.toProtobuf()
    }

    if let key = key {
      body.key = key.toProtobuf()
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.cryptoCreateAccount = build()
  }
}
