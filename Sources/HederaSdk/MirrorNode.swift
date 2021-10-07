import GRPC
import HederaProtoServices
import NIO

class MirrorNode: ManagedNode {
    var consensusServiceClient: Proto_ConsensusServiceClient?

    convenience init?(_ address: String) {
        let managedNodeAddress = ManagedNodeAddress(address)

        self.init(managedNodeAddress!)
    }

    func getConsensusServiceClient() -> Proto_ConsensusServiceClient {
        if let consensusServiceClient = consensusServiceClient {
            return consensusServiceClient
        }

        consensusServiceClient = Proto_ConsensusServiceClient(channel: getConnection())
        return consensusServiceClient!
    }
}
