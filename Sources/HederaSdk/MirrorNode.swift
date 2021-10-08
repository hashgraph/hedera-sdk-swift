import GRPC
import HederaProtoServices
import NIO

class MirrorNode: ManagedNode<String> {
  var consensus: Proto_ConsensusServiceClient?

  convenience init?(_ address: String) {
    if let managedNodeAddress = ManagedNodeAddress(address) {
      self.init(managedNodeAddress)
      return
    }

    return nil
  }

  override func getKey() -> String {
    address.description
  }

  func getConsensus() -> Proto_ConsensusServiceClient {
    if let consensus = consensus {
      return consensus
    }

    consensus = Proto_ConsensusServiceClient(channel: getConnection())
    return consensus!
  }
}
