import Foundation
import GRPC
import HederaCrypto
import HederaProtoServices
import NIO

public final class ContractExecuteTransaction: Transaction {
  var contractId: ContractId?
  var gas: Int64 = 0
  var amount: Int64 = 0
  var parameters: Data?

  @discardableResult
  public func setContractId(_ contractId: ContractId) -> Self {
    self.contractId = contractId
    return self
  }

  @discardableResult
  public func setGas(_ gas: Int64) -> Self {
    self.gas = gas
    return self
  }

  @discardableResult
  public func setAmount(_ amount: Int64) -> Self {
    self.amount = amount
    return self
  }

  @discardableResult
  public func setParameters(_ parameters: Data) -> Self {
    self.parameters = parameters
    return self
  }

  public func getContractId() -> ContractId? {
    contractId
  }

  public func getGas() -> Int64 {
    gas
  }

  public func getAmount() -> Int64 {
    amount
  }

  public func getParameters() -> Data? {
    parameters
  }

  convenience init(_ proto: Proto_TransactionBody) {
    self.init()

    setContractId(ContractId(proto.contractCall.contractID))
    setGas(proto.contractCall.gas)
    setAmount(proto.contractCall.amount)
    setParameters(proto.contractCall.functionParameters)
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Transaction, CallOptions?) ->
    UnaryCall<
      Proto_Transaction, Proto_TransactionResponse
    >
  {
    nodes[circular: index].getContract().contractCallMethod
  }

  func build() -> Proto_ContractCallTransactionBody {
    var body = Proto_ContractCallTransactionBody()
    body.gas = gas
    body.amount = amount

    if let contractId = contractId {
      body.contractID = contractId.toProtobuf()
    }

    if let parameters = parameters {
      body.functionParameters = parameters
    }

    return body
  }

  override func onFreeze(_ body: inout Proto_TransactionBody) {
    body.contractCall = build()
  }
}
