import GRPC
import NIO

class MirrorNetwork: ManagedNetwork<MirrorNode, String, [String]> {
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

  override func getNodesToRemove(_ network: [String]) -> [Int] {
    self.network.enumerated().compactMap {
      network.contains($0.element.key) ? nil : $0.offset
    }.reversed()
  }

  override func checkNetworkContainsEntry(_ entry: String) -> Bool {
    network.contains(where: { $0.key == entry })
  }
}
