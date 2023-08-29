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

internal final class TokenMintTransactionTests: XCTestCase {
    private static let testTokenId: TokenId = "4.2.0"
    private static let testAmount: UInt64 = 10
    private static let testMetadata = [Data([1, 2, 3, 4, 5])]

    private static func makeTransaction() throws -> TokenMintTransaction {
        try TokenMintTransaction()
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .tokenId(testTokenId)
            .amount(testAmount)
            .freeze()
    }

    private static func makeMetadataTransaction() throws -> TokenMintTransaction {
        try TokenMintTransaction()
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .tokenId(testTokenId)
            .metadata(testMetadata)
            .freeze()
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

    internal func testSerializeMetadata() throws {
        let tx = try Self.makeMetadataTransaction().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytesMetadata() throws {
        let tx = try Self.makeMetadataTransaction()

        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testFromProtoBody() throws {
        let protoData = Proto_TokenMintTransactionBody.with { proto in
            proto.token = Self.testTokenId.toProtobuf()
            proto.amount = Self.testAmount
            proto.metadata = Self.testMetadata
        }

        let protoBody = Proto_TransactionBody.with { proto in
            proto.tokenMint = protoData
            proto.transactionID = Resources.txId.toProtobuf()
        }

        let tx = try TokenMintTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.tokenId, Self.testTokenId)
        XCTAssertEqual(tx.amount, Self.testAmount)
        XCTAssertEqual(tx.metadata, Self.testMetadata)
    }

    internal func testGetSetTokenId() {
        let tx = TokenMintTransaction()
        tx.tokenId(Self.testTokenId)

        XCTAssertEqual(tx.tokenId, Self.testTokenId)
    }

    internal func testGetSetAmount() {
        let tx = TokenMintTransaction()
        tx.amount(Self.testAmount)

        XCTAssertEqual(tx.amount, Self.testAmount)
    }

    internal func testGetSetMetadata() {
        let tx = TokenMintTransaction()
        tx.metadata(Self.testMetadata)

        XCTAssertEqual(tx.metadata, Self.testMetadata)
    }
}
