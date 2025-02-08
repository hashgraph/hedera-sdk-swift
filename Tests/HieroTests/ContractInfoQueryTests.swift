// SPDX-License-Identifier: Apache-2.0

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class ContractInfoQueryTests: XCTestCase {
    internal func testSerialize() throws {
        let query = try ContractInfoQuery()
            .contractId(ContractId.fromString("0.0.5005"))
            .toQueryProtobufWith(.init())

        assertSnapshot(matching: query, as: .description)
    }

    internal func testGetSetContractId() {
        let query = ContractInfoQuery()
        query.contractId(5005)

        XCTAssertEqual(query.contractId, 5005)
    }
}
