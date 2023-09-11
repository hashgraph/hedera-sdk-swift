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

import SnapshotTesting
import XCTest

@testable import Hedera

internal final class ScheduleInfoQueryTests: XCTestCase {
    internal func testSerialize() throws {
        let query = try ScheduleInfoQuery()
            .scheduleId(ScheduleId.fromString("0.0.5005"))
            .toQueryProtobufWith(.init())

        assertSnapshot(matching: query, as: .description)
    }

    internal func testGetSetScheduleId() throws {
        let query = ScheduleInfoQuery()
        query.scheduleId(Resources.scheduleId)

        XCTAssertEqual(query.scheduleId, Resources.scheduleId)
    }
}
