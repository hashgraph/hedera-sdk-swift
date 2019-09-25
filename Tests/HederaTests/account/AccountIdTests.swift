import XCTest
import Hedera

final class AccountIdTests: XCTestCase {
    static let allTests = [
        ("testToString", testToString),
        ("testFromString", testFromString),
        ("testFromBadStrings", testFromBadStrings),
    ]

    func testToString() {
        let id = AccountId(shard: 1, realm: 2, account: 3)
        XCTAssertEqual(String(id), "1.2.3")
    }

    func testFromString() {
        let id = AccountId("0.0.2")
        XCTAssertNotNil(id)

        let otherId = AccountId("2")
        XCTAssertNotNil(otherId)
        XCTAssertEqual(otherId, id)
    }

    func testFromBadStrings() {
        var id = AccountId("0.0")
        XCTAssertNil(id)

        id = AccountId("a")
        XCTAssertNil(id)

        id = AccountId("a.2.3")
        XCTAssertNil(id)

        id = AccountId("1.b.3")
        XCTAssertNil(id)

        id = AccountId("1.2.c")
        XCTAssertNil(id)

        id = AccountId("1.2.3.4")
        XCTAssertNil(id)
    }
}
