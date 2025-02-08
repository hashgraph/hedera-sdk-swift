// SPDX-License-Identifier: Apache-2.0

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class TokenInfoQueryTests: XCTestCase {
    internal func testSerialize() {
        let query = TokenInfoQuery()
            .tokenId("4.2.0")
            .toQueryProtobufWith(.init())

        assertSnapshot(matching: query, as: .description)
    }

    internal func testGetSetTokenId() {
        let query = TokenInfoQuery()

        query.tokenId("4.2.0")

        XCTAssertEqual(query.tokenId, "4.2.0")
    }
}
