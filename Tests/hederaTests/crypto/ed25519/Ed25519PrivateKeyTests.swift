import XCTest
import Sodium
import hedera

final class Ed25519PrivateKeyTests: XCTestCase {
    let testKeyStr = "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"
    let testKeyPem = "-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEINtIS4KOZLLY8SzjwKDpOguMznrxu485yXcyOUSCU44Q\n-----END PRIVATE KEY-----\n"

    func testGenerate() {
        XCTAssertNoThrow(Ed25519PrivateKey.generate())
    }

    func testFromString() {
        let key = Ed25519PrivateKey.from(string: testKeyStr)
        XCTAssertNoThrow(try! key.get())
    }

    static var allTests = [
        ("testGenerate", testGenerate),
        ("testFromString", testFromString),
    ]
}
