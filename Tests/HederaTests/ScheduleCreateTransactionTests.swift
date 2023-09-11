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

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class ScheduleCreateTransactionTests: XCTestCase {
    internal static let testMemo = "test memo"

    private static func makeTransaction() throws -> ScheduleCreateTransaction {
        let transferTx = try TransferTransaction()
            .hbarTransfer(AccountId.fromString("0.0.555"), -10)
            .hbarTransfer(AccountId.fromString("0.0.321"), 10)

        return try transferTx.schedule()
            .nodeAccountIds([AccountId("0.0.5005"), AccountId("0.0.5006")])
            .transactionId(
                TransactionId(
                    accountId: 5006, validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false)
            )
            .adminKey(.single(Resources.publicKey))
            .payerAccountId(AccountId.fromString("0.0.222"))
            .scheduleMemo("flook")
            .maxTransactionFee(1)
            .expirationTime(Timestamp(seconds: 1_554_158_567, subSecondNanos: 0))
            .freeze()
            .sign(Resources.privateKey)
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
        let protoData = Proto_ScheduleCreateTransactionBody.with { proto in
            proto.adminKey = Key.single(Resources.publicKey).toProtobuf()
            proto.expirationTime = Resources.validStart.toProtobuf()
            proto.payerAccountID = Resources.accountId.toProtobuf()
            proto.memo = "Flook"
            proto.waitForExpiry = true
        }

        let protoBody = Proto_TransactionBody.with { proto in
            proto.scheduleCreate = protoData
            proto.transactionID = Resources.txId.toProtobuf()
        }

        let tx = try ScheduleCreateTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.adminKey, Key.single(Resources.publicKey))
        XCTAssertEqual(tx.expirationTime, Resources.validStart)
        XCTAssertEqual(tx.payerAccountId?.num, Resources.accountId.num)
        XCTAssertEqual(tx.scheduleMemo, "Flook")
        XCTAssertEqual(tx.isWaitForExpiry, true)
    }

    internal func testGetSetPayerAccountId() throws {
        let tx = ScheduleCreateTransaction()
        tx.payerAccountId(Resources.accountId)

        XCTAssertEqual(tx.payerAccountId, Resources.accountId)
    }

    internal func testGetSetAdminKey() throws {
        let tx = ScheduleCreateTransaction()
        tx.adminKey(.single(Resources.publicKey))

        XCTAssertEqual(tx.adminKey, .single(Resources.publicKey))
    }

    internal func testGetSetExpirationTime() throws {
        let tx = ScheduleCreateTransaction()
        tx.expirationTime(Resources.validStart)

        XCTAssertEqual(tx.expirationTime, Resources.validStart)
    }

    internal func testGetSetScheduleMemo() throws {
        let tx = ScheduleCreateTransaction()
        tx.scheduleMemo(Self.testMemo)

        XCTAssertEqual(tx.scheduleMemo, Self.testMemo)
    }

}
