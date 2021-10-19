    import XCTest
    @testable import HederaSdk

    final class HashgraphSdkTests: XCTestCase {
        func testSetNetwork() {
            var client = try! Client.forNetwork([:]).wait()

            let defaultNetwork: [String: AccountId] = [
                "0.testnet.hedera.com:50211": AccountId(3),
                "1.testnet.hedera.com:50211": AccountId(4),
            ]

            client = try! client.setNetwork(defaultNetwork).wait()
            XCTAssertEqual(client.getNetwork(), defaultNetwork)

            client = try! client.setNetwork(defaultNetwork).wait()
            XCTAssertEqual(client.getNetwork(), defaultNetwork)

            let defaultNetworkWithExtraNode: [String: AccountId] = [
                "0.testnet.hedera.com:50211": AccountId(3),
                "1.testnet.hedera.com:50211": AccountId(4),
                "2.testnet.hedera.com:50211": AccountId(5),
            ]

            client = try! client.setNetwork(defaultNetworkWithExtraNode).wait()
            XCTAssertEqual(client.getNetwork(), defaultNetworkWithExtraNode)

            let singleNodeNetwork: [String: AccountId] = [
                "2.testnet.hedera.com:50211": AccountId(5),
            ]

            client = try! client.setNetwork(singleNodeNetwork).wait()
            XCTAssertEqual(client.getNetwork(), singleNodeNetwork)

            let singleNodeNetworkWithDifferentAccountId: [String: AccountId] = [
                "2.testnet.hedera.com:50211": AccountId(6),
            ]

            client = try! client.setNetwork(singleNodeNetworkWithDifferentAccountId).wait()
            XCTAssertEqual(client.getNetwork(), singleNodeNetworkWithDifferentAccountId)
        }

        func testSetMirrorNetwork() {
            var client = try! Client.forNetwork([:]).wait()

            let defaultNetwork: [String] = [
                "0.testnet.hedera.com:5600",
            ]

            client = try! client.setMirrorNetwork(defaultNetwork).wait()
            XCTAssertEqual(client.getMirrorNetwork(), defaultNetwork)

            client = try! client.setMirrorNetwork(defaultNetwork).wait()
            XCTAssertEqual(client.getMirrorNetwork(), defaultNetwork)

            let defaultNetworkWithExtraNode: [String] = [
                "0.testnet.hedera.com:5600",
                "1.testnet.hedera.com:5600",
            ]

            client = try! client.setMirrorNetwork(defaultNetworkWithExtraNode).wait()
            XCTAssertEqual(client.getMirrorNetwork(), defaultNetworkWithExtraNode)

            let singleNodeNetwork: [String] = [
                "1.testnet.hedera.com:5600",
            ]

            client = try! client.setMirrorNetwork(singleNodeNetwork).wait()
            XCTAssertEqual(client.getMirrorNetwork(), singleNodeNetwork)

            let singleNodeNetworkWithDifferentAccountId: [String] = [
                "2.testnet.hedera.com:5600",
            ]

            client = try! client.setMirrorNetwork(singleNodeNetworkWithDifferentAccountId).wait()
            XCTAssertEqual(client.getMirrorNetwork(), singleNodeNetworkWithDifferentAccountId)
        }

        func testEntityId() {
            var client = try! Client.forTestnet().wait()
            if let id = try? AccountId("0.0.123-rmkyk") {
                try! id.validate(client)
                XCTAssertEqual(String(id.account), "123")
            }
//            if let id2 = try? AccountId("0.0.123-rmdjg") {
//                XCTAssertThrowsError(try id2.validate(client)) { error in
//                    XCTAssertEqual(error as! EntityIdError, EntityIdError.wrongChecksum("Invalid ID: checksum does not match, possible network mismatch"))
//                }
//            }
//            if let id = try? ContractId("0.0.123-rmkyk") {
//                try! id.validate(client)
//                XCTAssertEqual(String(id.contract), "123")
//            }
//            if let id2 = try? ContractId("0.0.123-rmdjg") {
//                XCTAssertThrowsError(try id2.validate(client)) { error in
//                    XCTAssertEqual(error as! EntityIdError, EntityIdError.wrongChecksum("Invalid ID: checksum does not match, possible network mismatch"))
//                }
//            }
//            if let id = try? TokenId("0.0.123-rmkyk") {
//                try! id.validate(client)
//                XCTAssertEqual(String(id.token), "123")
//            }
//            if let id2 = try? TokenId("0.0.123-rmdjg") {
//                XCTAssertThrowsError(try id2.validate(client)) { error in
//                    XCTAssertEqual(error as! EntityIdError, EntityIdError.wrongChecksum("Invalid ID: checksum does not match, possible network mismatch"))
//                }
//            }
        }
    }
