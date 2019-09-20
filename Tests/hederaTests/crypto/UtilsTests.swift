import XCTest
@testable import hedera

final class UtilsTests: XCTestCase {
    let testKeyStr = "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"
    
    func testDecodeEncode() {
        let decoded = try! hexDecode(testKeyStr).get()
        let encoded = hexEncode(bytes: decoded, prefixed: "")
        XCTAssertEqual(testKeyStr, encoded)
    }
    
    static var allTests = [
        ("testDecodeEncode", testDecodeEncode),
    ]
}
