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
import XCTest

internal class TopicMessageSubmit: XCTestCase {
    internal func testBasic() async throws {
        let testEnv = try TestEnvironment.nonFree

        let topic = try await Topic.create(testEnv)

        addTeardownBlock {
            try await topic.delete(testEnv)
        }

        _ = try await TopicMessageSubmitTransaction()
            .topicId(topic.id)
            .message("Hello, from HCS!".data(using: .utf8)!)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let info = try await TopicInfoQuery(topicId: topic.id).execute(testEnv.client)

        XCTAssertEqual(info.topicId, topic.id)
        XCTAssertEqual(info.sequenceNumber, 1)
    }

    internal func testLargeMessage() async throws {
        let testEnv = try TestEnvironment.nonFree
        async let bigContents = Resources.bigContents.data(using: .utf8)!

        let topic = try await Topic.create(testEnv)

        addTeardownBlock {
            try await topic.delete(testEnv)
        }

        let responses = try await TopicMessageSubmitTransaction()
            .topicId(topic.id)
            .maxChunks(15)
            .message(bigContents)
            .executeAll(testEnv.client)

        for response in responses {
            _ = try await response.getReceipt(testEnv.client)
        }

        let info = try await TopicInfoQuery(topicId: topic.id).execute(testEnv.client)

        XCTAssertEqual(info.topicId, topic.id)
        XCTAssertEqual(info.sequenceNumber, 14)
    }

    internal func testMissingTopicIdFails() async throws {
        let testEnv = try TestEnvironment.nonFree
        let bigContents = try await Resources.bigContents.data(using: .utf8)!

        await assertThrowsHErrorAsync(
            try await TopicMessageSubmitTransaction()
                .maxChunks(15)
                .message(bigContents)
                .execute(testEnv.client)
                .getReceipt(testEnv.client),
            "expected topic delete to fail"
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .invalidTopicID)
        }
    }

    internal func testMissingMessageFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let topic = try await Topic.create(testEnv)

        addTeardownBlock {
            try await topic.delete(testEnv)
        }

        await assertThrowsHErrorAsync(
            try await TopicMessageSubmitTransaction()
                .topicId(topic.id)
                .execute(testEnv.client)
                .getReceipt(testEnv.client),
            "expected topic delete to fail"
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .invalidTopicMessage)
        }
    }

    internal func testDecodeHexRegressionTest() throws {
        let transactionBytes = Data(
            hex:
                """
                2ac2010a580a130a0b08d38f8f880610a09be91512041899e11c120218041880\
                c2d72f22020878da01330a0418a5a12012103030303030303136323736333737\
                31351a190a130a0b08d38f8f880610a09be91512041899e11c1001180112660a\
                640a20603edaec5d1c974c92cb5bee7b011310c3b84b13dc048424cd6ef146d6\
                a0d4a41a40b6a08f310ee29923e5868aac074468b2bde05da95a806e2f4a4f45\
                2177f129ca0abae7831e595b5beaa1c947e2cb71201642bab33fece5184b0454\
                7afc40850a
                """
        )

        let transaction = try Transaction.fromBytes(transactionBytes)

        _ = try XCTUnwrap(transaction.transactionId)
    }
}
