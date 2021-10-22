import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class ContractCreateTransaction: Transaction {
  var byteCodeFileId: FileId?
  var proxyAccountId: AccountId?
  var adminKey: Key?
  var gas: Int64 = 0
  var initialBalance: Hbar?
  var autoRenewPeriod: TimeInterval = DEFAULT_AUTO_RENEW_PERIOD
  var parameters: Data?
  var contractMemo: String?

  @discardableResult
  public func setByteCodeFileId(_ fileId: FileId) -> Self {
    byteCodeFileId = fileId
    return self
  }

  @discardableResult
  public func setProxyAccountId(_ accountId: AccountId) -> Self {
    proxyAccountId = accountId
    return self
  }

  @discardableResult
  public func setAdminKey(_ key: Key) -> Self {
    adminKey = key
    return self
  }

  @discardableResult
  public func setGas(_ gas: Int64) -> Self {
    self.gas = gas
    return self
  }

  @discardableResult
  public func setInitialBalance(_ balance: Hbar) -> Self {
    initialBalance = balance
    return self
  }

  @discardableResult
  public func setAutoRenewPeriod(_ time: TimeInterval) -> Self {
    autoRenewPeriod = time
    return self
  }

  @discardableResult
  public func setParameters(_ parameters: Data) -> Self {
    self.parameters = parameters
    return self
  }

  @discardableResult
  public func setContractMemo(_ memo: String) -> Self {
    contractMemo = memo
    return self
  }

  public func getByteCodeFileId() -> FileId? {
    byteCodeFileId
  }

  public func getProxyAccountId() -> AccountId? {
    proxyAccountId
  }

  public func getAdminKey() -> Key? {
    adminKey
  }

  public func getGas() -> Int64 {
    gas
  }

  public func getInitialBalance() -> Hbar? {
    initialBalance
  }

  public func getAutoRenewPeriod() -> TimeInterval {
    autoRenewPeriod
  }

  public func getParameters() -> Data? {
    parameters
  }

  public func getContractMemo() -> String? {
    contractMemo
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setByteCodeFileId(FileId(proto.contractCreateInstance.fileID))
    setProxyAccountId(AccountId(proto.contractCreateInstance.proxyAccountID))
    setAdminKey(Key.fromProtobuf(proto.contractCreateInstance.adminKey)!)
    setContractMemo(proto.contractCreateInstance.memo)
    setAutoRenewPeriod(TimeInterval(proto.contractCreateInstance.autoRenewPeriod.seconds))
    setInitialBalance(Hbar.fromTinybars(proto.contractCreateInstance.initialBalance))
    setParameters(proto.contractCreateInstance.constructorParameters)
    setGas(proto.contractCreateInstance.gas)
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getContract().createContract
  }

  func build() -> Proto_ContractCreateTransactionBody {
    var body = Proto_ContractCreateTransactionBody()
    body.autoRenewPeriod = autoRenewPeriod.toProtobuf()
    body.gas = gas

    if let parameters = parameters {
      body.constructorParameters = parameters
    }

    if let byteCodeFileId = byteCodeFileId {
      body.fileID = byteCodeFileId.toProtobuf()
    }

    if let contractMemo = contractMemo {
      body.memo = contractMemo
    }

    if let initialBalance = initialBalance {
      body.initialBalance = initialBalance.tinybars
    }

    if let proxyAccountId = proxyAccountId {
      body.proxyAccountID = proxyAccountId.toProtobuf()
    }

    if let adminKey = adminKey {
      body.adminKey = adminKey.toProtobuf()
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.contractCreateInstance = build()
  }
}
