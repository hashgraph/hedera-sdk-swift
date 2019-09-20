import XCTest
import Sodium
@testable import hedera

let privateKeyString = "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"
let rawPrivateKeyString = "db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"
let privateKeyBytes = Array<UInt8>(arrayLiteral: 219, 72, 75, 130, 142, 100, 178, 216, 241, 44, 227, 192, 160, 233, 58, 11, 140, 206, 122, 241, 187, 143, 57, 201, 119,  50, 57, 68, 130, 83, 142, 16)

let combinedKeyBytes = Array<UInt8>(arrayLiteral: 219, 72, 75, 130, 142, 100, 178, 216, 241, 44, 227, 192, 160, 233, 58, 11, 140, 206, 122, 241, 187, 143, 57, 201, 119,  50, 57, 68, 130, 83, 142, 16, 224, 200, 236, 39, 88, 165, 135, 159, 250, 194, 38, 161, 60, 12, 81, 107, 121, 158, 114, 227, 81, 65, 160, 221, 130, 143, 148, 211, 121, 136, 164, 183)

//let testKeyPem = "-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEINtIS4KOZLLY8SzjwKDpOguMznrxu485yXcyOUSCU44Q\n-----END PRIVATE KEY-----\n"

final class Ed25519PrivateKeyTests: XCTestCase {
    func testGenerate() {
        XCTAssertNoThrow(Ed25519PrivateKey.generate())
    }

    func testFromBytes() {
        let key = Ed25519PrivateKey.from(bytes: privateKeyBytes)
        XCTAssertNoThrow(try key.get())
    }

    func testFromCombinedBytes() {
        let key = Ed25519PrivateKey.from(bytes: combinedKeyBytes)
        XCTAssertNoThrow(try key.get())
    }

    func testFromBadBytes() {
        let key = Ed25519PrivateKey.from(bytes: Array<UInt8>(arrayLiteral: 1, 2, 3))
        XCTAssertThrowsError(try key.get())
    }

    func testFromString() {
        let key = Ed25519PrivateKey(privateKeyString)
        let bytesKey = try! Ed25519PrivateKey.from(bytes: privateKeyBytes).get()
        XCTAssertNotNil(key)
        XCTAssertEqual(key!.inner, bytesKey.inner)
    }

    func testFromRawString() {
        let key = Ed25519PrivateKey(rawPrivateKeyString)
        let bytesKey = try! Ed25519PrivateKey.from(bytes: privateKeyBytes).get()
        XCTAssertNotNil(key)
        XCTAssertEqual(key!.inner, bytesKey.inner)
    }

    func testFromBadString() {
        let key = Ed25519PrivateKey("notaprivatekey")
        XCTAssertNil(key)
    }

    func testGetPublicKey() {
        let key = try! Ed25519PrivateKey.from(bytes: privateKeyBytes).get()
        let publicFromPrivate = key.getPublicKey()
        let publicKey = try! Ed25519PublicKey.from(bytes: publicKeyBytes).get()
        XCTAssertEqual(publicFromPrivate.description, publicKey.description)
    }

    static var allTests = [
        ("testGenerate", testGenerate),
        ("testFromBytes", testFromBytes),
        ("testFromBadBytes", testFromBadBytes),
        ("testFromString", testFromString),
        ("testFromRawString", testFromRawString),
        ("testFromBadString", testFromBadString),
        ("testGetPublicKey", testGetPublicKey),
    ]
}
