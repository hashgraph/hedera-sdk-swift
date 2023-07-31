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

internal class ContractCallQueryTests: XCTestCase {
    internal static let unusedPrivateKey: PrivateKey =
        "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

    private static func makeQuery() -> ContractCallQuery {
        ContractCallQuery(contractId: 5005, gas: 1541, senderAccountId: "1.2.3").maxPaymentAmount(100_000)
    }

    internal func testSerialize() throws {
        let query = Self.makeQuery().toQueryProtobufWith(.init())

        assertSnapshot(matching: query, as: .description)
    }

    internal func testFunctionParameters() throws {
        let params = ContractFunctionParameters().addString("hello").addString("world!").toBytes()
        let query = Self.makeQuery()
            .functionParameters(params).toQueryProtobufWith(.init())

        assertSnapshot(matching: query, as: .description)
    }
}
