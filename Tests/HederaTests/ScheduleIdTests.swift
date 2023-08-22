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

internal final class ScheduleIdTests: XCTestCase {
    internal func testParse() {
        XCTAssertEqual(try ScheduleId.fromString("0.0.1001"), ScheduleId(num: 1001))
    }

    internal func testToFromBytesRoundtrip() {
        let scheduleId = ScheduleId(num: 1001)

        XCTAssertEqual(scheduleId, try ScheduleId.fromBytes(scheduleId.toBytes()))
    }

    internal func testGoodChecksumOnMainnet() throws {
        let scheduleId = try ScheduleId.fromString("0.0.123-vfmkw")
        try scheduleId.validateChecksums(on: .mainnet)
    }

    internal func testGoodChecksumOnTestnet() throws {
        let scheduleId = try ScheduleId.fromString("0.0.123-esxsf")
        try scheduleId.validateChecksums(on: .testnet)
    }

    internal func testGoodChecksumOnPreviewnet() throws {
        let scheduleId = try ScheduleId.fromString("0.0.123-ogizo")
        try scheduleId.validateChecksums(on: .previewnet)
    }

    internal func testToStringWithChecksum() {
        let client = Client.forTestnet()

        XCTAssertEqual(
            "0.0.123-esxsf",
            try ScheduleId.fromString("0.0.123").toStringWithChecksum(client)
        )
    }

    internal func testBadChecksumOnPreviewnet() throws {
        let scheduleId = try ScheduleId.fromString("0.0.123-ntjli")

        XCTAssertThrowsError(try scheduleId.validateChecksums(on: .previewnet))
    }

    internal func testMalformedIdFails() {
        XCTAssertThrowsError(try ScheduleId.fromString("0.0."))
    }

    internal func testMalformedChecksum() {
        XCTAssertThrowsError(try ScheduleId.fromString("0.0.123-ntjl"))
    }

    internal func testMalformedChecksum2() {
        XCTAssertThrowsError(try ScheduleId.fromString("0.0.123-ntjl1"))
    }

    internal func testMalformedAlias() {
        XCTAssertThrowsError(
            try ScheduleId.fromString(
                "0.0.302a300506032b6570032100114e6abc371b82dab5c15ea149f02d34a012087b163516dd70f44acafabf777"))
    }
    internal func testMalformedAlias2() {
        XCTAssertThrowsError(
            try ScheduleId.fromString(
                "0.0.302a300506032b6570032100114e6abc371b82dab5c15ea149f02d34a012087b163516dd70f44acafabf777g"))
    }
    internal func testMalformedAliasKey3() {
        XCTAssertThrowsError(
            try ScheduleId.fromString(
                "0.0.303a300506032b6570032100114e6abc371b82dab5c15ea149f02d34a012087b163516dd70f44acafabf7777"))
    }

    internal func testFromSolidityAddress() {
        assertSnapshot(
            matching: try ScheduleId.fromSolidityAddress("000000000000000000000000000000000000138D"),
            as: .description
        )
    }

    internal func testFromSolidityAddress0x() {
        assertSnapshot(
            matching: try ScheduleId.fromSolidityAddress("0x000000000000000000000000000000000000138D"),
            as: .description
        )
    }

    internal func testFromBytes() {
        assertSnapshot(
            matching: try ScheduleId.fromBytes(ScheduleId(num: 5005).toBytes()),
            as: .description
        )
    }

    internal func testToSolidityAddress() {
        assertSnapshot(
            matching: try ScheduleId(num: 5005).toSolidityAddress(),
            as: .lines
        )
    }
}
