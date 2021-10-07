import GRPC
import NIO

class MirrorNetwork: ManagedNetwork<MirrorNode, String, [String]> {
    var maxNodesPerRequest: UInt32?

    static func forNetwork(_ eventLoopGroup: EventLoopGroup, _ network: [String])
                    -> EventLoopFuture<MirrorNetwork>
    {
        MirrorNetwork(eventLoopGroup).setNetwork(network)
    }

    static func forPreviewnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<MirrorNetwork> {
        var network = [String]()
        network.append("hcs.previewnet.mirrornode.hedera.com:5600")

        return MirrorNetwork(eventLoopGroup).setNetwork(network)
    }

    static func forTestnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<MirrorNetwork> {
        var network = [String]()
        network.append("hcs.testnet.mirrornode.hedera.com:5600")

        return MirrorNetwork(eventLoopGroup).setNetwork(network)
    }

    static func forMainnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<MirrorNetwork> {
        var network = [String]()
        network.append("hcs.mainnet.mirrornode.hedera.com:5600")

        return MirrorNetwork(eventLoopGroup).setNetwork(network)
    }

    func getNetwork() -> [String] {
        var arr = [String]()
        for entry in network{
            arr.append(entry.key)
        }

        return arr
    }

    func getNumberOfMostHealthyNodes(_ count: Int) -> ArraySlice<MirrorNode> {
        nodes[0..<count]
    }

    func getNumberOfNodesPerRequest() -> Int {
        if let maxNodesPerRequest = maxNodesPerRequest {
            return max(Int(maxNodesPerRequest), nodes.count)
        } else {
            return (nodes.count + 3 - 1) / 3
        }
    }

    override func createNodeFromNetworkEntry(_ entry: String) -> MirrorNode? {
        MirrorNode(entry)
    }

    override func addNodeToNetwork(_ node: MirrorNode) {
        network[node.address.description] = node
    }

    override func getNodesToRemove(_ network: [String]) -> [Int] {
        var arr = [Int]()
        for entry in super.network {
            arr = network.indices.filter {network[$0] == entry.key}
        }

        return arr
    }

    override func removeNodeFromNetwork(_ node: MirrorNode) {
        network.removeValue(forKey: node.address.description)
    }

    override func checkNetworkContainsEntry(_ entry: String) -> Bool {
        network.contains(where: { $0.key == entry })
    }
}
