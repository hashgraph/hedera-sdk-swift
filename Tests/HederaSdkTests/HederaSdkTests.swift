    import XCTest
    @testable import HederaSdk

    final class HashgraphSdkTests: XCTestCase {
        func testSetNetwork() {
            var client = try! Client.forTestnet().wait()

            var nodes: [String: AccountId] = [:]
            nodes["0.testnet.hedera.com:50211"] = AccountId.init(3)
            nodes["1.testnet.hedera.com:50211"] = AccountId.init(4)
            client = try! client.setNetwork(nodes).wait()

//            var mir = client.getMirrorNetwork()!
//            print(mir.count)

            var network = client.getNetwork()!
            XCTAssertEqual(network.count, 2)
            XCTAssertEqual(network["0.testnet.hedera.com:50211"]!, AccountId.init(3))
            XCTAssertEqual(network["1.testnet.hedera.com:50211"]!, AccountId.init(4))

            nodes.removeAll()
            nodes["0.testnet.hedera.com:50211"] = AccountId.init(3)
            nodes["1.testnet.hedera.com:50211"] = AccountId.init(4)
            nodes["2.testnet.hedera.com:50211"] = AccountId.init(5)
            client = try! client.setNetwork(nodes).wait()

            network.removeAll()
            network = client.getNetwork()!
            XCTAssertEqual(network.count, 3)
            XCTAssertEqual(network["0.testnet.hedera.com:50211"]!, AccountId.init(3))
            XCTAssertEqual(network["1.testnet.hedera.com:50211"]!, AccountId.init(4))
            XCTAssertEqual(network["2.testnet.hedera.com:50211"]!, AccountId.init(5))

            nodes.removeAll()
            nodes["2.testnet.hedera.com:50211"] = AccountId.init(5)
            client = try! client.setNetwork(nodes).wait()

            network.removeAll()
            network = client.getNetwork()!
            XCTAssertEqual(network.count, 1)
            XCTAssertEqual(network["2.testnet.hedera.com:50211"]!, AccountId.init(5))
        }

//        func testSetMirrorNetwork() {
//            var client = try! Client.forTestnet().wait()
//
//            var nodes: [String: AccountId] = [:]
//            nodes["0.testnet.hedera.com:50211"] = AccountId.init(3)
//            nodes["1.testnet.hedera.com:50211"] = AccountId.init(4)
//            client = try! client.setNetwork(nodes).wait()
//
//            var network = client.getNetwork()!
//            XCTAssertEqual(network.count, 2)
//            XCTAssertEqual(network["0.testnet.hedera.com:50211"]!, AccountId.init(3))
//            XCTAssertEqual(network["1.testnet.hedera.com:50211"]!, AccountId.init(4))
//
//            nodes.removeAll()
//            nodes["0.testnet.hedera.com:50211"] = AccountId.init(3)
//            nodes["1.testnet.hedera.com:50211"] = AccountId.init(4)
//            nodes["2.testnet.hedera.com:50211"] = AccountId.init(5)
//            client = try! client.setNetwork(nodes).wait()
//
//            network.removeAll()
//            network = client.getNetwork()!
//            XCTAssertEqual(network.count, 3)
//            XCTAssertEqual(network["0.testnet.hedera.com:50211"]!, AccountId.init(3))
//            XCTAssertEqual(network["1.testnet.hedera.com:50211"]!, AccountId.init(4))
//            XCTAssertEqual(network["2.testnet.hedera.com:50211"]!, AccountId.init(5))
//
//            nodes.removeAll()
//            nodes["2.testnet.hedera.com:50211"] = AccountId.init(5)
//            client = try! client.setNetwork(nodes).wait()
//
//            network.removeAll()
//            network = client.getNetwork()!
//            XCTAssertEqual(network.count, 1)
//            XCTAssertEqual(network["2.testnet.hedera.com:50211"]!, AccountId.init(5))
//        }
    }
