// SPDX-License-Identifier: Apache-2.0

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class FileContentsQueryTests: XCTestCase {
    internal func testSerialize() throws {
        let query = try FileContentsQuery()
            .fileId(FileId.fromString("0.0.5005"))
            .toQueryProtobufWith(.init())

        assertSnapshot(matching: query, as: .description)
    }

    internal func testGetSetFileId() throws {
        let query = FileContentsQuery()
        query.fileId(Resources.fileId)

        XCTAssertEqual(query.fileId, Resources.fileId)
    }
}
