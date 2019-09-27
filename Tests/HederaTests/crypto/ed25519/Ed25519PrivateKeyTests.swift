import XCTest
import Sodium
@testable import Hedera

let privateKeyString = "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"
let rawPrivateKeyString = "db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"
let privateKeyBytes = Array<UInt8>(arrayLiteral: 219, 72, 75, 130, 142, 100, 178, 216, 241, 44, 227, 192, 160, 233, 58, 11, 140, 206, 122, 241, 187, 143, 57, 201, 119,  50, 57, 68, 130, 83, 142, 16)

let combinedKeyBytes = Array<UInt8>(arrayLiteral: 219, 72, 75, 130, 142, 100, 178, 216, 241, 44, 227, 192, 160, 233, 58, 11, 140, 206, 122, 241, 187, 143, 57, 201, 119,  50, 57, 68, 130, 83, 142, 16, 224, 200, 236, 39, 88, 165, 135, 159, 250, 194, 38, 161, 60, 12, 81, 107, 121, 158, 114, 227, 81, 65, 160, 221, 130, 143, 148, 211, 121, 136, 164, 183)

//let testKeyPem = "-----BEGIN PRIVATE KEY-----\nMC4CAQAwBQYDK2VwBCIEINtIS4KOZLLY8SzjwKDpOguMznrxu485yXcyOUSCU44Q\n-----END PRIVATE KEY-----\n"

let message = "This is a message about the world."
let signature = "73bea53f31ca9c42a422ecb7516ec08d0bbd1a6bfd630ccf10ec1872454814d29f4a8011129cd007eab544af01a75f508285b591e5bed24b68f927751e49e30e"

final class Ed25519PrivateKeyTests: XCTestCase {
    func testGenerate() {
        XCTAssertNoThrow(Ed25519PrivateKey())
    }

    func testFromBytes() {
        let key = Ed25519PrivateKey(bytes: privateKeyBytes)
        XCTAssertNotNil(key)
    }

    func testFromCombinedBytes() {
        let key = Ed25519PrivateKey(bytes: combinedKeyBytes)
        XCTAssertNotNil(key)
    }

    func testFromBadBytes() {
        let key = Ed25519PrivateKey(bytes: Array<UInt8>(arrayLiteral: 1, 2, 3))
        XCTAssertNil(key)
    }

    func testFromString() {
        let key = Ed25519PrivateKey(privateKeyString)
        let bytesKey = Ed25519PrivateKey(bytes: privateKeyBytes)

        XCTAssertNotNil(key)
        XCTAssertNotNil(bytesKey)
        XCTAssertEqual(key!.bytes, bytesKey!.bytes)
    }

    func testFromRawString() {
        let key = Ed25519PrivateKey(rawPrivateKeyString)
        let bytesKey = Ed25519PrivateKey(bytes: privateKeyBytes)

        XCTAssertNotNil(key)
        XCTAssertNotNil(bytesKey)
        XCTAssertEqual(key!.bytes, bytesKey!.bytes)
    }

    func testFromBadString() {
        let key = Ed25519PrivateKey("notaprivatekey")
        XCTAssertNil(key)
    }

    func testGetPublicKey() {
        let key = Ed25519PrivateKey(bytes: privateKeyBytes)
        let publicFromPrivate = key!.publicKey
        let publicKey = Ed25519PublicKey(bytes: publicKeyBytes)!

        XCTAssertEqual(String(publicFromPrivate), String(publicKey))
    }

    func testSign() {
        let key = Ed25519PrivateKey(privateKeyString)!
        let sig = key.sign(message: message.bytes)

        XCTAssertEqual(hexEncode(bytes: sig), signature)
    }

    static var allTests = [
        ("testGenerate", testGenerate),
        ("testFromBytes", testFromBytes),
        ("testFromBadBytes", testFromBadBytes),
        ("testFromString", testFromString),
        ("testFromRawString", testFromRawString),
        ("testFromBadString", testFromBadString),
        ("testGetPublicKey", testGetPublicKey),
        ("testSign", testSign),
    ]
}
