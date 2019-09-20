import XCTest
@testable import hedera

final class Ed25519PublicKeyTests: XCTestCase {
    let testKeyStr = "302a300506032b6570032100e0c8ec2758a5879ffac226a13c0c516b799e72e35141a0dd828f94d37988a4b7"

    func testFromBytes() {
        
    }
    
    func testFromString() {
        let key = Ed25519PublicKey.from(string: testKeyStr)
        XCTAssertNoThrow(try! key.get())
    }
    
    func testToString() {
        let key = Ed25519PublicKey.from(string: testKeyStr)
        XCTAssertEqual(String(try! key.get()), testKeyStr)
    }
    
    static var allTests = [
        ("testFromBytes", testFromBytes),
        ("testFromString", testFromString),
        ("testToString", testToString),
    ]
}
