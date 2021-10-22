import GRPC
import HederaProtoServices
import NIO

public final class ContractBytecodeQuery: Query<ContractFunctionResult> {
  var contractId: ContractId? = nil

  @discardableResult
  public func setContractId(_ contractId: ContractId) -> Self {
    self.contractId = contractId
    return self
  }

  public func getContractId() -> ContractId? {
    contractId
  }

  convenience init(_ proto: Proto_Query) {
    self.init()

    setContractId(ContractId(proto.contractGetBytecode.contractID))
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Query, CallOptions?) ->
    UnaryCall<Proto_Query, Proto_Response>
  {
    nodes[circular: index].getContract().contractGetBytecode
  }

  override func onMakeRequest(_ proto: inout Proto_Query) {
    // TODO: What happens if we don't d this
    proto.contractGetBytecode = Proto_ContractGetBytecodeQuery()

    if let contractId = contractId {
      proto.contractGetBytecode.contractID = contractId.toProtobuf()
    }
  }

  override func onFreeze(_ query: inout Proto_Query, _ header: Proto_QueryHeader) {
    query.contractGetBytecode.header = header
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.contractCallLocal.header
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> ContractFunctionResult {
    ContractFunctionResult(response.contractCallLocal.functionResult)!
  }
}
