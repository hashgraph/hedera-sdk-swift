import GRPC
import NIO

// https://stackoverflow.com/questions/41383937/reverse-swift-dictionary-lookup
extension Dictionary where Value: Equatable {
  func key(forValue value: Value) -> Key? {
    first { $0.1 == value }?.0
  }
}

class Network: ManagedNetwork<Node, AccountId, [String: AccountId]> {
  var maxNodesPerRequest: UInt32?

  static func forNetwork(_ eventLoopGroup: EventLoopGroup, _ network: [String: AccountId])
    -> EventLoopFuture<Network>
  {
    Network(eventLoopGroup).setNetwork(network)
  }

  static func forPreviewnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<Network> {
    var network: [String: AccountId] = [:]
    network["0.previewnet.hedera.com:50211"] = AccountId(3)
    network["1.previewnet.hedera.com:50211"] = AccountId(4)
    network["2.previewnet.hedera.com:50211"] = AccountId(5)
    network["3.previewnet.hedera.com:50211"] = AccountId(6)
    network["4.previewnet.hedera.com:50211"] = AccountId(7)

    return Network(eventLoopGroup).setNetwork(network)
  }

  static func forTestnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<Network> {
    var network: [String: AccountId] = [:]
    network["0.testnet.hedera.com:50211"] = AccountId(3)
    network["1.testnet.hedera.com:50211"] = AccountId(4)
    network["2.testnet.hedera.com:50211"] = AccountId(5)
    network["3.testnet.hedera.com:50211"] = AccountId(6)
    network["4.testnet.hedera.com:50211"] = AccountId(7)

    return Network(eventLoopGroup).setNetwork(network)
  }

  static func forMainnet(_ eventLoopGroup: EventLoopGroup) -> EventLoopFuture<Network> {
    var network: [String: AccountId] = [:]
    network["35.237.200.180:50211"] = AccountId(3)
    network["35.186.191.247:50211"] = AccountId(4)
    network["35.192.2.25:50211"] = AccountId(5)
    network["35.199.161.108:50211"] = AccountId(6)
    network["35.203.82.240:50211"] = AccountId(7)
    network["35.236.5.219:50211"] = AccountId(8)
    network["35.197.192.225:50211"] = AccountId(9)
    network["35.242.233.154:50211"] = AccountId(10)
    network["35.240.118.96:50211"] = AccountId(11)
    network["35.204.86.32:50211"] = AccountId(12)
    network["35.234.132.107:50211"] = AccountId(13)
    network["35.236.2.27:50211"] = AccountId(14)
    network["35.228.11.53:50211"] = AccountId(15)
    network["34.91.181.183:50211"] = AccountId(16)
    network["34.86.212.247:50211"] = AccountId(17)
    network["172.105.247.67:50211"] = AccountId(18)
    network["34.89.87.138:50211"] = AccountId(19)
    network["34.82.78.255:50211"] = AccountId(20)

    return Network(eventLoopGroup).setNetwork(network)
  }

  func getNetwork() -> [String: AccountId] {
    Dictionary(uniqueKeysWithValues: network.map { ($1.address.description, $0) })
  }

  func getNumberOfNodesPerRequest() -> Int {
    if let maxNodesPerRequest = maxNodesPerRequest {
      return max(Int(maxNodesPerRequest), nodes.count)
    } else {
      return (nodes.count + 3 - 1) / 3
    }
  }

  func getNodeAccountIdsForExecute() -> EventLoopFuture<[AccountId]> {
    getNumberOfMostHealthyNodes(getNumberOfNodesPerRequest()).map { $0.map { $0.accountId } }
  }

  override func createNodeFromNetworkEntry(_ entry: (String, AccountId)) -> Node? {
    Node(entry.0, entry.1)
  }

  override func addNodeToNetwork(_ node: Node) {
    network[node.accountId] = node
  }

  override func getNodesToRemove(_ network: [String: AccountId]) -> [Int] {
    stride(from: nodes.count - 1, to: 0, by: -1).compactMap { i in
      network.key(forValue: nodes[i].accountId).map { _ in i }
    }
  }

  override func removeNodeFromNetwork(_ node: Node) {
    network.removeValue(forKey: node.accountId)
  }

  override func checkNetworkContainsEntry(_ entry: (String, AccountId)) -> Bool {
    network.contains(where: { $0.key == entry.1 })
  }
}
