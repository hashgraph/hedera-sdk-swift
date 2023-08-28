/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2023 - 2023 Hedera Hashgraph, LLC
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

internal final class TokenNftAllowanceTests: XCTestCase {
    private func makeAllowance() throws -> TokenNftAllowance {
        TokenNftAllowance.init(
            tokenId: try TokenId.fromString("1.2.3"),
            ownerAccountId: AccountId(num: 5006),
            spenderAccountId: AccountId(num: 5007),
            serials: [1, 2],
            approvedForAll: true,
            delegatingSpenderAccountId: AccountId(num: 5008)
        )
    }

    internal func testSerialize() throws {
        let allowance = try makeAllowance()

        assertSnapshot(matching: allowance, as: .description)
    }
}
