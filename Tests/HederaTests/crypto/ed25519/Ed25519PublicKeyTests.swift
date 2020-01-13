import XCTest
@testable import Hedera

let publicKeyString = "302a300506032b6570032100e0c8ec2758a5879ffac226a13c0c516b799e72e35141a0dd828f94d37988a4b7"
let rawPublicKeyString = "e0c8ec2758a5879ffac226a13c0c516b799e72e35141a0dd828f94d37988a4b7"
let publicKeyBytes = Array<UInt8>(arrayLiteral: 224, 200, 236, 39, 88, 165, 135, 159, 250, 194, 38, 161, 60, 12, 81, 107, 121, 158, 114, 227, 81, 65, 160, 221, 130, 143, 148, 211, 121, 136, 164, 183)

final class Ed25519PublicKeyTests: XCTestCase {
    func testFromBytes() {
        let key = Ed25519PublicKey(bytes: publicKeyBytes)
        XCTAssertNotNil(key)
    }

    func testFromBadBytes() {
        let key = Ed25519PublicKey(bytes: Array<UInt8>(arrayLiteral: 1, 2, 3))
        XCTAssertNil(key)
    }

    func testFromString() {
        let key = Ed25519PublicKey(publicKeyString)
        XCTAssertNotNil(key)
    }

    func testFromRawString() {
        let key = Ed25519PublicKey(rawPublicKeyString)
        XCTAssertNotNil(key)
    }

    func testFromBadString() {
        let key = Ed25519PublicKey("notapublickeynotapublickeylickey")
        XCTAssertNil(key)
    }

    func testToString() {
        let key = Ed25519PublicKey(publicKeyString)
        XCTAssertEqual(String(key!), publicKeyString)
    }

    func testVerify() {
        let key = Ed25519PublicKey(publicKeyString)!
        let verified =  key.verify(signature: sodium.utils.hex2bin(signature)!, of: Array(message.utf8))
        XCTAssertTrue(verified)
    }

    static var allTests = [
        ("testFromBytes", testFromBytes),
        ("testFromBadBytes", testFromBadBytes),
        ("testFromString", testFromString),
        ("testFromRawString", testFromRawString),
        ("testFromBadString", testFromBadString),
        ("testToString", testToString),
        ("testVerify", testVerify),
    ]
}
