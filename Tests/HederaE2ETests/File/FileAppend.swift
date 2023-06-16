/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
 * ​
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ‍
 */

import Hedera
import HederaExampleUtilities
import SnapshotTesting
import XCTest

internal final class FileAppend: XCTestCase {
    internal func testBasic() async throws {
        // There are potential bugs in FileAppendTransaction which require more than one node to trigger.
        let testEnv = try TestEnvironment.nonFree

        // assumeNotLocalNode

        let file = try await File.forContent("[swift::e2e::fileUpdate::1]", testEnv)

        addTeardownBlock {
            try await file.delete(testEnv)
        }

        _ = try await FileAppendTransaction()
            .fileId(file.fileId)
            .contents("update")
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let info = try await FileInfoQuery(fileId: file.fileId).execute(testEnv.client)

        XCTAssertEqual(info.fileId, file.fileId)
        XCTAssertEqual(info.size, 33)
    }

    internal func testLargeContents() async throws {
        // There are potential bugs in FileAppendTransaction which require more than one node to trigger.
        let testEnv = try TestEnvironment.nonFree

        // assumeNotLocalNode

        async let bigContents = Resources.bigContents

        let file = try await File.forContent("[swift::e2e::fileUpdate::2]", testEnv)

        addTeardownBlock {
            try await file.delete(testEnv)
        }

        try await testEnv.ratelimits.file()
        _ = try await FileAppendTransaction()
            .fileId(file.fileId)
            .contents(bigContents)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        try await testEnv.ratelimits.file()
        let contents = try await FileContentsQuery().fileId(file.fileId).execute(testEnv.client)

        // marginally better to do a snapshot here, even though it's uncolored, at least there's a lot less text being shown.
        await assertSnapshotAsync(matching: String(data: contents.contents, encoding: .utf8)!, as: .lines)

        let info = try await FileInfoQuery(fileId: file.fileId).execute(testEnv.client)

        XCTAssertEqual(info.fileId, file.fileId)
        XCTAssertEqual(info.size, 13521)
    }

    internal func testSmallValidDurationLargeContents() async throws {
        // There are potential bugs in FileAppendTransaction which require more than one node to trigger.
        let testEnv = try TestEnvironment.nonFree

        // assumeNotLocalNode

        async let bigContents = Resources.bigContents

        let file = try await File.forContent("[swift::e2e::fileUpdate::3]", testEnv)

        addTeardownBlock {
            try await file.delete(testEnv)
        }

        _ = try await FileAppendTransaction()
            .fileId(file.fileId)
            .contents(bigContents)
            .transactionValidDuration(.seconds(25))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let contents = try await FileContentsQuery().fileId(file.fileId).execute(testEnv.client)

        // marginally better to do a snapshot here, even though it's uncolored, at least there's a lot less text being shown.
        await assertSnapshotAsync(matching: String(data: contents.contents, encoding: .utf8)!, as: .lines)

        let info = try await FileInfoQuery(fileId: file.fileId).execute(testEnv.client)

        XCTAssertEqual(info.fileId, file.fileId)
        XCTAssertEqual(info.size, 13521)
    }
}
