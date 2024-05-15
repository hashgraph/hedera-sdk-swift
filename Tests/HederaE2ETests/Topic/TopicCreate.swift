/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2024 Hedera Hashgraph, LLC
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
import XCTest

internal class TopicCreate: XCTestCase {
    internal func testBasic() async throws {
        let testEnv = try TestEnvironment.nonFree

        let receipt = try await TopicCreateTransaction()
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .topicMemo("[e2e::TopicCreateTransaction]")
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let topicId = try XCTUnwrap(receipt.topicId)

        let topic = Topic(id: topicId)

        try await topic.delete(testEnv)
    }

    internal func testFieldless() async throws {
        let testEnv = try TestEnvironment.nonFree

        let receipt = try await TopicCreateTransaction()
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        _ = try XCTUnwrap(receipt.topicId)
    }
}
