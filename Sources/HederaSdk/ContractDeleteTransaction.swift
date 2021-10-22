import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class ContractDeleteTransaction: Transaction {
  var contractId: ContractId?
  var transferContractId: ContractId?
  var transferAccountId: AccountId?

  @discardableResult
  public func setContractId(_ contractId: ContractId) -> Self {
    self.contractId = contractId
    return self
  }

  @discardableResult
  public func setTransferContractId(_ contractId: ContractId) -> Self {
    transferContractId = contractId
    return self
  }

  @discardableResult
  public func setTransferAccountId(_ accountId: AccountId) -> Self {
    transferAccountId = accountId
    return self
  }

  public func getContractId() -> ContractId? {
    contractId
  }

  public func getTransferContractId() -> ContractId? {
    transferContractId
  }

  public func getTransferAccountId() -> AccountId? {
    transferAccountId
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setContractId(ContractId(proto.contractDeleteInstance.contractID))
    setTransferAccountId(AccountId(proto.contractDeleteInstance.transferAccountID))
    setTransferContractId(ContractId(proto.contractDeleteInstance.transferContractID))
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getContract().deleteContract
  }

  func build() -> Proto_ContractDeleteTransactionBody {
    var body = Proto_ContractDeleteTransactionBody()

    if let contractId = contractId {
      body.contractID = contractId.toProtobuf()
    }

    if let transferContractId = transferContractId {
      body.transferContractID = transferContractId.toProtobuf()
    }

    if let transferAccountId = transferAccountId {
      body.transferAccountID = transferAccountId.toProtobuf()
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.contractDeleteInstance = build()
  }
}
