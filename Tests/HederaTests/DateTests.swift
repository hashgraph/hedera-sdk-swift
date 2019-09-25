import XCTest
import SwiftProtobuf
@testable import Hedera

final class DateTests: XCTestCase {
    static var allTests = [
        ("testFromProto", testFromProto),
    ]

    func testFromProto() {
        var proto = Proto_Timestamp()
        proto.seconds = 5
        proto.nanos = 2500

        let date = Date(proto)
        XCTAssertNotNil(date)
    }
}
