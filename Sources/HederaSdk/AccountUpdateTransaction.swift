import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO
import SwiftProtobuf

public final class AccountUpdateTransaction: Transaction {
  var accountId: AccountId?
  var proxyAccountId: AccountId?
  var key: Key?
  var receiveRecordThreshold: UInt64 = 0
  var sendRecordThreshold: UInt64 = 0
  var accountMemo: String?
  var receiversSigRequired = false
  var autoRenewPeriod: TimeInterval = DEFAULT_AUTO_RENEW_PERIOD
  var expirationTime: Date?

  @discardableResult
  public func setAccountId(_ accountId: AccountId) -> Self {
    self.accountId = accountId
    return self
  }

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
  public func setExpirationTime(_ time: Date?) -> Self {
    expirationTime = time
    return self
  }

  @discardableResult
  public func setAccountMemo(_ memo: String) -> Self {
    accountMemo = memo
    return self
  }

  public func getAccountId() -> AccountId? {
    accountId
  }

  public func getProxyAccountId() -> AccountId? {
    proxyAccountId
  }

  public func getKey() -> Key? {
    key
  }

  public func getReceiverSignatureRequired() -> Bool {
    receiversSigRequired
  }

  public func getAutoRenewPeriod() -> TimeInterval {
    autoRenewPeriod
  }

  public func getExpirationTime() -> Date? {
    expirationTime
  }

  public func getAccountMemo() -> String? {
    accountMemo
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setAccountId(AccountId(proto.cryptoUpdateAccount.accountIdtoUpdate))
    setProxyAccountId(AccountId(proto.cryptoUpdateAccount.proxyAccountID))
    setKey(Key.fromProtobuf(proto.cryptoUpdateAccount.key)!)
    receiveRecordThreshold = proto.cryptoUpdateAccount.receiveRecordThreshold
    sendRecordThreshold = proto.cryptoUpdateAccount.sendRecordThreshold
    setAccountMemo(proto.cryptoUpdateAccount.memo.value)
    setAutoRenewPeriod(TimeInterval(proto.cryptoUpdateAccount.autoRenewPeriod.seconds))
    setReceiverSignatureRequired(proto.cryptoUpdateAccount.receiverSigRequired)
    setExpirationTime(Date(proto.cryptoUpdateAccount.expirationTime))
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getCrypto().updateAccount
  }

  func build() -> Proto_CryptoUpdateTransactionBody {
    var body = Proto_CryptoUpdateTransactionBody()
    body.receiverSigRequired = receiversSigRequired
    body.autoRenewPeriod = autoRenewPeriod.toProtobuf()
    body.sendRecordThreshold = sendRecordThreshold
    body.receiveRecordThreshold = receiveRecordThreshold

    if let accountId = accountId {
      body.accountIdtoUpdate = accountId.toProtobuf()
    }

    if let accountMemo = accountMemo {
      var result = SwiftProtobuf.Google_Protobuf_StringValue()
      result.value = accountMemo

      body.memo = result
    }

    if let proxyAccountId = proxyAccountId {
      body.proxyAccountID = proxyAccountId.toProtobuf()
    }

    if let key = key {
      body.key = key.toProtobuf()
    }

    if let expirationTime = expirationTime {
      body.expirationTime = expirationTime.toProtobuf()
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.cryptoUpdateAccount = build()
  }
}
