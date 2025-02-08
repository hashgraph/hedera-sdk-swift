// SPDX-License-Identifier: Apache-2.0

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

// SPDX-License-Identifier: Apache-2.0

internal class AccountRecordsQueryTests: XCTestCase {
    internal func testSerialize() throws {
        let query = AccountRecordsQuery(accountId: AccountId(num: 5005))
            .toQueryProtobufWith(.init())

        assertSnapshot(matching: query, as: .description)
    }

    internal func testGetSetAccountId() {
        let query = AccountRecordsQuery()
        query.accountId(5005)

        XCTAssertEqual(query.accountId, 5005)
    }
}
