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

internal final class TopicCreateTransactionTests: XCTestCase {
    private static let testTxId: TransactionId = TransactionId(
        accountId: 5006,
        validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0)
    )

    private static let unusedPrivateKey: PrivateKey =
        "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

    private static let testAutoRenewAccountId: AccountId = "0.0.5007"
    private static let testAutoRenewPeriod: Duration = .days(1)

    private static func makeTransaction() throws -> TopicCreateTransaction {
        try TopicCreateTransaction()
            .nodeAccountIds([5005, 5006])
            .transactionId(testTxId)
            .submitKey(.single(unusedPrivateKey.publicKey))
            .adminKey(.single(unusedPrivateKey.publicKey))
            .autoRenewAccountId(testAutoRenewAccountId)
            .autoRenewPeriod(testAutoRenewPeriod)
            .freeze()
            .sign(unusedPrivateKey)
    }

    internal func testSerialize() throws {
        let tx = try Self.makeTransaction().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytes() throws {
        let tx = try Self.makeTransaction()

        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testFromProtoBody() throws {
        let protoData = Proto_ConsensusCreateTopicTransactionBody.with { proto in
            proto.submitKey = (Self.unusedPrivateKey.publicKey).toProtobuf()
            proto.adminKey = (Self.unusedPrivateKey.publicKey).toProtobuf()
            proto.autoRenewAccount = Self.testAutoRenewAccountId.toProtobuf()
            proto.autoRenewPeriod = Self.testAutoRenewPeriod.toProtobuf()
        }

        let protoBody = Proto_TransactionBody.with { proto in
            proto.consensusCreateTopic = protoData
            proto.transactionID = Self.testTxId.toProtobuf()
        }

        let tx = try TopicCreateTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.submitKey, .single(Self.unusedPrivateKey.publicKey))
        XCTAssertEqual(tx.adminKey, .single(Self.unusedPrivateKey.publicKey))
        XCTAssertEqual(tx.autoRenewAccountId, Self.testAutoRenewAccountId)
        XCTAssertEqual(tx.autoRenewPeriod, Self.testAutoRenewPeriod)
    }

    internal func testGetSetSubmitKey() {
        let tx = TopicCreateTransaction()
        tx.submitKey(.single(Self.unusedPrivateKey.publicKey))

        XCTAssertEqual(tx.submitKey, .single(Self.unusedPrivateKey.publicKey))
    }

    internal func testGetSetAdminKey() {
        let tx = TopicCreateTransaction()
        tx.adminKey(.single(Self.unusedPrivateKey.publicKey))

        XCTAssertEqual(tx.adminKey, .single(Self.unusedPrivateKey.publicKey))
    }

    internal func testGetSetAutoRenewAccountId() {
        let tx = TopicCreateTransaction()
        tx.autoRenewAccountId(Self.testAutoRenewAccountId)

        XCTAssertEqual(tx.autoRenewAccountId, Self.testAutoRenewAccountId)
    }

    internal func testGetSetAutoRenewPeriod() {
        let tx = TopicCreateTransaction()
        tx.autoRenewPeriod(Self.testAutoRenewPeriod)

        XCTAssertEqual(tx.autoRenewPeriod, Self.testAutoRenewPeriod)
    }
}
