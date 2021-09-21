import GRPC
import NIO

class Network {
    var network: [AccountId:Node] = [:]
    var nodes: [Node] = []
    var networkName: NetworkName?
    var eventLoopGroup: EventLoopGroup

    init(_ network: [String: AccountId]) {
        for (url, accountId) in network {
            let node = Node(url, accountId)
            nodes.append(node)
            self.network[accountId] = node
        }

        eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    }

    static func forNetwork(_ network: [String: AccountId]) -> Network {
        Network(network)
    }

    static func forPreviewnet() -> Network {
        var network: [String:AccountId] = [:]
        network["0.previewnet.hedera.com:50211"] = AccountId(3)
        network["1.previewnet.hedera.com:50211"] = AccountId(4)
        network["2.previewnet.hedera.com:50211"] = AccountId(5)
        network["3.previewnet.hedera.com:50211"] = AccountId(6)
        network["4.previewnet.hedera.com:50211"] = AccountId(7)

        return Network(network)
    }

    static func forTestnet() -> Network {
        var network: [String:AccountId] = [:]
        network["0.testnet.hedera.com:50211"] = AccountId(3)
        network["1.testnet.hedera.com:50211"] = AccountId(4)
        network["2.testnet.hedera.com:50211"] = AccountId(5)
        network["3.testnet.hedera.com:50211"] = AccountId(6)
        network["4.testnet.hedera.com:50211"] = AccountId(7)

        return Network(network)
    }

    static func forMainnet() -> Network {
        var network: [String:AccountId] = [:]
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

        return Network(network)
    }

    deinit {
        try! eventLoopGroup.syncShutdownGracefully()
    }

    func getNetwork() -> [String:AccountId] {
        Dictionary(uniqueKeysWithValues: network.map { ($1.address.description, $0) })
    }

    @discardableResult
    func setNetworkName(_ networkName: NetworkName) -> Self {
        self.networkName = networkName
        return self
    }

    func getNetworkName() -> NetworkName? {
        networkName
    }
}
