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

internal final class TokenWipeTransactionTests: XCTestCase {
    private static let testAccountId: AccountId = "0.6.9"
    private static let testTokenId: TokenId = "4.2.0"
    private static let testAmount: UInt64 = 4
    private static let testSerials: [UInt64] = [8, 9, 10]

    private static func makeTransaction() throws -> TokenWipeTransaction {
        try TokenWipeTransaction()
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .tokenId(testTokenId)
            .accountId(testAccountId)
            .amount(testAmount)
            .freeze()
    }

    private static func makeTransactionNft() throws -> TokenWipeTransaction {
        try TokenWipeTransaction()
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .tokenId(testTokenId)
            .accountId(testAccountId)
            .serials(testSerials)
            .freeze()
    }

    internal func testSerializeFungible() throws {
        let tx = try Self.makeTransaction().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytesFungieble() throws {
        let tx = try Self.makeTransaction()

        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testSerializeNft() throws {
        let tx = try Self.makeTransactionNft().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytesNft() throws {
        let tx = try Self.makeTransactionNft()

        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testFromProtoBody() throws {
        let protoData = Proto_TokenWipeAccountTransactionBody.with { proto in
            proto.token = Self.testTokenId.toProtobuf()
            proto.account = Self.testAccountId.toProtobuf()
            proto.amount = Self.testAmount
            proto.serialNumbers = Self.testSerials.map(Int64.init(bitPattern:))
        }

        let protoBody = Proto_TransactionBody.with { proto in
            proto.tokenWipe = protoData
            proto.transactionID = Resources.txId.toProtobuf()
        }

        let tx = try TokenWipeTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.tokenId, Self.testTokenId)
        XCTAssertEqual(tx.accountId, Self.testAccountId)
        XCTAssertEqual(tx.amount, Self.testAmount)
        XCTAssertEqual(tx.serials, Self.testSerials)

    }

    internal func testGetSetTokenId() {
        let tx = TokenWipeTransaction()
        tx.tokenId(Self.testTokenId)

        XCTAssertEqual(tx.tokenId, Self.testTokenId)
    }

    internal func testGetSetAccountId() {
        let tx = TokenWipeTransaction()
        tx.accountId(Self.testAccountId)

        XCTAssertEqual(tx.accountId, Self.testAccountId)
    }

    internal func testGetSetAmount() {
        let tx = TokenWipeTransaction()
        tx.amount(Self.testAmount)

        XCTAssertEqual(tx.amount, Self.testAmount)
    }

    internal func testGetSetSerialNumbers() {
        let tx = TokenWipeTransaction()
        tx.serials(Self.testSerials)

        XCTAssertEqual(tx.serials, Self.testSerials)
    }
}
