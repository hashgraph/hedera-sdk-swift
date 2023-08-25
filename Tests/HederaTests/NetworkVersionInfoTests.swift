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

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class NetworkVersionInfoTests: XCTestCase {
    private static let info: NetworkVersionInfo = NetworkVersionInfo(protobufVersion: "1.2.3", servicesVersion: "4.5.6")

    internal func testSerialize() {
        assertSnapshot(matching: Self.info.toProtobuf(), as: .description)
    }

    internal func testToFromBytes() throws {
        let a = Self.info
        let b = try NetworkVersionInfo.fromBytes(a.toBytes())

        XCTAssertEqual(String(describing: a.protobufVersion), String(describing: b.protobufVersion))
        XCTAssertEqual(String(describing: a.servicesVersion), String(describing: b.servicesVersion))
    }
}
