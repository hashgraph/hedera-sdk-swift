import GRPC
import HederaProtoServices
import NIO

class MirrorNode: ManagedNode {
  var consensus: Proto_ConsensusServiceClient?

  convenience init?(_ address: String) {
    if let managedNodeAddress = ManagedNodeAddress(address) {
      self.init(managedNodeAddress)
    }

    return nil
  }

  func getConsensus() -> Proto_ConsensusServiceClient {
    if let consensus = consensus {
      return consensus
    }

    consensus = Proto_ConsensusServiceClient(channel: getConnection())
    return consensus!
  }
}
