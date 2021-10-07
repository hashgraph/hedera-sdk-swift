import GRPC
import NIO

class MirrorNetwork: ManagedNetwork<MirrorNode, String, [String]> {
  var maxNodesPerRequest: UInt32?

  static func forNetwork(_ eventLoopGroup: EventLoopGroup, _ network: [String]) -> EventLoopFuture<
    MirrorNetwork
  > {
    MirrorNetwork(eventLoopGroup).setNetwork(network)
  }

  static func forPreviewnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<MirrorNetwork> {
    MirrorNetwork(eventLoopGroup).setNetwork(["hcs.previewnet.mirrornode.hedera.com:5600"])
  }

  static func forTestnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<MirrorNetwork> {
    MirrorNetwork(eventLoopGroup).setNetwork(["hcs.testnet.mirrornode.hedera.com:5600"])
  }

  static func forMainnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<MirrorNetwork> {
    MirrorNetwork(eventLoopGroup).setNetwork(["hcs.mainnet.mirrornode.hedera.com:5600"])
  }

  func getNetwork() -> [String] {
    network.map { $0.key }
  }

  func getNumberOfNodesPerRequest() -> Int {
    maxNodesPerRequest.map {
      max(Int($0), nodes.count)
    } ?? (nodes.count + 3 - 1) / 3
  }

  override func createNodeFromNetworkEntry(_ entry: String) -> MirrorNode? {
    MirrorNode(entry)
  }

  override func addNodeToNetwork(_ node: MirrorNode) {
    network[node.address.description] = node
  }

  override func getNodesToRemove(_ network: [String]) -> [Int] {
    self.network.enumerated().compactMap {
      network.contains($0.element.key) ? $0.offset : nil
    }
  }

  override func removeNodeFromNetwork(_ node: MirrorNode) {
    network.removeValue(forKey: node.address.description)
  }

  override func checkNetworkContainsEntry(_ entry: String) -> Bool {
    network.contains(where: { $0.key == entry })
  }
}
