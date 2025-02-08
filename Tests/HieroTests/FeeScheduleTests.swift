/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2025 Hiero LLC
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

@testable import Hiero

internal final class FeeScheduleTests: XCTestCase {
    private static func makeFeeComponent(_ min: UInt64, _ max: UInt64) -> FeeComponents {
        FeeComponents(
            min: min, max: max, constant: 0, bandwidthByte: 0, verification: 0, storageByteHour: 0, ramByteHour: 0,
            contractTransactionGas: 0, transferVolumeHbar: 0, responseMemoryByte: 0, responseDiskByte: 0)
    }

    private let feeSchedule: FeeSchedule =
        FeeSchedule.init(
            transactionFeeSchedules: [
                TransactionFeeSchedule(
                    requestType: nil,
                    fees: [
                        FeeData.init(
                            node: makeFeeComponent(0, 0), network: makeFeeComponent(2, 5),
                            service: makeFeeComponent(0, 0), kind: FeeDataType.default)
                    ])
            ], expirationTime: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0))

    internal func testSerialize() throws {
        assertSnapshot(matching: feeSchedule, as: .description)
    }

    internal func testToFromBytes() throws {
        assertSnapshot(matching: try FeeSchedule.fromBytes(feeSchedule.toBytes()), as: .description)
    }

    internal func testFromProtobuf() throws {
        let feeSchedule = try FeeSchedule.fromProtobuf(feeSchedule.toProtobuf())

        assertSnapshot(matching: feeSchedule, as: .description)
    }

    internal func testToProtobuf() throws {
        let protoFeeSchedule = feeSchedule.toProtobuf()

        assertSnapshot(matching: protoFeeSchedule, as: .description)
    }
}
