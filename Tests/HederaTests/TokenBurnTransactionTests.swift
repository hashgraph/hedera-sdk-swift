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

internal final class TokenBurnTransactionTests: XCTestCase {
    private static func createTransaction() throws -> TokenBurnTransaction {
        try TokenBurnTransaction()
            .nodeAccountIds([AccountId("0.0.5005"), AccountId("0.0.5006")])
            .transactionId(
                TransactionId(
                    accountId: 5005, validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false)
            )
            .tokenId(TokenId.fromString("0.1.2"))
            .amount(54)
            .maxTransactionFee(1)
            .freeze()
            .sign(Resources.privateKey)
    }

    private static func createTransactionNft() throws -> TokenBurnTransaction {
        try TokenBurnTransaction()
            .nodeAccountIds([AccountId("0.0.5005"), AccountId("0.0.5006")])
            .transactionId(
                TransactionId(
                    accountId: 5005, validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false)
            )
            .tokenId(TokenId.fromString("0.1.2"))
            .maxTransactionFee(1)
            .setSerials([1, 2, 3])
            .freeze()
            .sign(Resources.privateKey)

    }

    internal func testSerialize() throws {
        let tx = try Self.createTransaction().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytes() throws {
        let tx = try Self.createTransaction()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testSerializeNft() throws {
        let tx = try Self.createTransactionNft().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytesNft() throws {
        let tx = try Self.createTransactionNft()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testSetGetTokenId() {
        let tx = TokenBurnTransaction.init()

        let tx2 = tx.tokenId("0.0.123")

        XCTAssertEqual(tx2.tokenId, try TokenId.fromString("0.0.123"))
    }

    internal func testSetGetSerials() throws {
        let tx = TokenBurnTransaction.init()

        let tx2 = tx.setSerials([1, 2, 3])

        XCTAssertEqual(tx2.serials, [1, 2, 3])
    }

    internal func testSetGetAmount() {
        let tx = TokenBurnTransaction.init()

        let tx2 = tx.amount(64)

        XCTAssertEqual(tx2.amount, 64)
    }
}
