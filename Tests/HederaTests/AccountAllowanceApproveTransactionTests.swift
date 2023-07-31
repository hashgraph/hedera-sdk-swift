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

internal class AccountAllowanceApproveTransactionTests: XCTestCase {
    internal static let unusedPrivateKey: PrivateKey =
        "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

    private static func makeTransaction() throws -> AccountAllowanceApproveTransaction {
        let ownerId: AccountId = "5.6.7"
        let tx = AccountAllowanceApproveTransaction()

        let invalidTokenIds: [TokenId] = [
            "2.2.2",
            "4.4.4",
            "6.6.6",
            "8.8.8",
        ]

        let invalidAccountIds: [AccountId] = [
            "1.1.1",
            "3.3.3",
            "5.5.5",
            "7.7.7",
            "9.9.9",
        ]

        try tx.nodeAccountIds(["0.0.5005", "0.0.5006"])
            .transactionId(
                TransactionId(
                    accountId: 5006,
                    validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0),
                    scheduled: false
                )
            )
            .approveHbarAllowance(ownerId, invalidAccountIds[0], Hbar(3))
            .approveTokenAllowance(invalidTokenIds[0], ownerId, invalidAccountIds[1], 6)
            .approveTokenNftAllowance(
                invalidTokenIds[1].nft(123),
                ownerId,
                invalidAccountIds[2]
            )
            .approveTokenNftAllowance(
                invalidTokenIds[1].nft(456),
                ownerId,
                invalidAccountIds[2]
            )
            .approveTokenNftAllowance(
                invalidTokenIds[3].nft(456),
                ownerId,
                invalidAccountIds[2]
            )
            .approveTokenNftAllowance(
                invalidTokenIds[1].nft(789),
                ownerId,
                invalidAccountIds[4]
            )
            .approveTokenNftAllowanceAllSerials(
                invalidTokenIds[2],
                ownerId,
                invalidAccountIds[3]
            )
            .maxTransactionFee(.fromTinybars(100_000))
            .freeze()
            .sign(unusedPrivateKey)

        return tx
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

    internal func testCheckProperties() throws {
        let tx = try Self.makeTransaction()

        XCTAssertFalse(tx.getHbarApprovals().isEmpty)
        XCTAssertFalse(tx.getTokenApprovals().isEmpty)
        XCTAssertFalse(tx.getNftApprovals().isEmpty)
    }
}
