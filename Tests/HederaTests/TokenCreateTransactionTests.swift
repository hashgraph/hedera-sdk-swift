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

internal final class TokenCreateTransactionTests: XCTestCase {
    internal static let unusedPrivateKey: PrivateKey =
        "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

    private static func createTransaction() throws -> TokenCreateTransaction {
        try TokenCreateTransaction()
            .nodeAccountIds([AccountId("0.0.5005"), AccountId("0.0.5006")])
            .transactionId(
                TransactionId(
                    accountId: 5005, validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false)
            )
            .initialSupply(30)
            .feeScheduleKey(.single(unusedPrivateKey.publicKey))
            .supplyKey(.single(unusedPrivateKey.publicKey))
            .adminKey(.single(unusedPrivateKey.publicKey))
            .autoRenewAccountId(AccountId.fromString("0.0.123"))
            .autoRenewPeriod(Duration.seconds(100))
            .decimals(3)
            .freezeDefault(true)
            .freezeKey(.single(unusedPrivateKey.publicKey))
            .wipeKey(.single(unusedPrivateKey.publicKey))
            .symbol("F")
            .kycKey(.single(unusedPrivateKey.publicKey))
            .pauseKey(.single(unusedPrivateKey.publicKey))
            .expirationTime(Timestamp(seconds: 1_554_158_557, subSecondNanos: 0))
            .treasuryAccountId(AccountId.fromString("0.0.456"))
            .name("flook")
            .tokenMemo("flook memo")
            .customFees([
                .fixed(
                    FixedFee(
                        amount: 3,
                        denominatingTokenId: try TokenId.fromString("4.3.2"),
                        feeCollectorAccountId: try AccountId.fromString("0.0.54")
                    ))
            ])
            .freeze()
            .sign(unusedPrivateKey)
    }

    private static func createTransactionNft() throws -> TokenCreateTransaction {
        try TokenCreateTransaction()
            .nodeAccountIds([AccountId("0.0.5005"), AccountId("0.0.5006")])
            .transactionId(
                TransactionId(
                    accountId: 5006, validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false)
            )
            .feeScheduleKey(.single(unusedPrivateKey.publicKey))
            .supplyKey(.single(unusedPrivateKey.publicKey))
            .maxSupply(500)
            .adminKey(.single(unusedPrivateKey.publicKey))
            .autoRenewAccountId(AccountId.fromString("0.0.123"))
            .autoRenewPeriod(Duration.seconds(100))
            .tokenSupplyType(TokenSupplyType.finite)
            .tokenType(TokenType.nonFungibleUnique)
            .freezeKey(.single(unusedPrivateKey.publicKey))
            .wipeKey(.single(unusedPrivateKey.publicKey))
            .symbol("F")
            .kycKey(.single(unusedPrivateKey.publicKey))
            .pauseKey(.single(unusedPrivateKey.publicKey))
            .expirationTime(Timestamp(seconds: 1_554_158_557, subSecondNanos: 0))
            .treasuryAccountId(AccountId.fromString("0.0.456"))
            .name("flook")
            .tokenMemo("flook memo")
            .freeze()
            .sign(unusedPrivateKey)
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

    internal func testProperties() throws {
        let tx = try Self.createTransaction()

        let unusedPrivateKey: PrivateKey =
            "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

        XCTAssertEqual(tx.name, "flook")
        XCTAssertEqual(tx.symbol, "F")
        XCTAssertEqual(tx.decimals, 3)
        XCTAssertEqual(tx.initialSupply, 30)
        XCTAssertEqual(tx.treasuryAccountId, "0.0.456")
        XCTAssertEqual(tx.adminKey, .single(unusedPrivateKey.publicKey))
        XCTAssertEqual(tx.kycKey, .single(unusedPrivateKey.publicKey))
        XCTAssertEqual(tx.freezeKey, .single(unusedPrivateKey.publicKey))
        XCTAssertEqual(tx.wipeKey, .single(unusedPrivateKey.publicKey))
        XCTAssertEqual(tx.feeScheduleKey, .single(unusedPrivateKey.publicKey))
        XCTAssertEqual(tx.pauseKey, .single(unusedPrivateKey.publicKey))
        XCTAssertEqual(tx.freezeDefault, true)
        XCTAssertEqual(tx.expirationTime, Timestamp(seconds: 1_554_158_557, subSecondNanos: 0))
        XCTAssertEqual(tx.autoRenewAccountId, try AccountId.fromString("0.0.123"))
        XCTAssertEqual(tx.tokenMemo, "flook memo")
        XCTAssertEqual(tx.tokenType, TokenType.fungibleCommon)
        XCTAssertEqual(tx.tokenSupplyType, TokenSupplyType.infinite)
        XCTAssertEqual(tx.maxSupply, 0)
    }
}
