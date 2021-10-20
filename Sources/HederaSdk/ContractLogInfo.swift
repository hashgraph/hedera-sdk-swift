import Foundation
import HederaProtoServices

public final class ContractLogInfo {
  public let contractId: ContractId?
  public let bloom: Data
  public let topics: [Data]
  public let data: Data

  init(_ contractId: ContractId?, _ bloom: Data, _ topics: [Data], _ data: Data) {
    self.contractId = contractId
    self.bloom = bloom
    self.topics = topics
    self.data = data
  }
}

extension ContractLogInfo: ProtobufConvertible {
  convenience init?(_ proto: Proto_ContractLoginfo) {
    self.init(
      proto.hasContractID ? ContractId(proto.contractID) : nil, proto.bloom, proto.topic, proto.data
    )
  }

  func toProtobuf() -> Proto_ContractLoginfo {
    var proto = Proto_ContractLoginfo()
    proto.bloom = bloom
    proto.topic = topics
    proto.data = data

    if let contractId = contractId {
      proto.contractID = contractId.toProtobuf()
    }

    return proto
  }
}
