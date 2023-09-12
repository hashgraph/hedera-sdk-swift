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

internal final class TokenAssociateTransactionTests: XCTestCase {
    private static func createTransaction() throws -> TokenAssociateTransaction {
        try TokenAssociateTransaction()
            .nodeAccountIds([AccountId("0.0.5005"), AccountId("0.0.5006")])
            .transactionId(
                TransactionId(
                    accountId: 5005, validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0), scheduled: false)
            )
            .accountId(AccountId.fromString("0.0.435"))
            .tokenIds([TokenId.fromString("1.2.3")])
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

    internal func testFromProtoBody() throws {
        let protoData = Proto_TokenAssociateTransactionBody.with { proto in
            proto.account = Resources.accountId.toProtobuf()
            proto.tokens = [Resources.tokenId.toProtobuf()]
        }

        let protoBody = Proto_TransactionBody.with { proto in
            proto.tokenAssociate = protoData
            proto.transactionID = Resources.txId.toProtobuf()
        }

        let tx = try TokenAssociateTransaction(protobuf: protoBody, protoData)

        XCTAssertEqual(tx.accountId, Resources.accountId)
        XCTAssertEqual(tx.tokenIds, [Resources.tokenId])
    }

    internal func testSetGetAccountId() {
        let tx = TokenAssociateTransaction.init()

        let tx2 = tx.accountId("0.0.123")

        XCTAssertEqual(tx2.accountId, try AccountId.fromString("0.0.123"))
    }

    internal func testSetGetTokenId() throws {
        let tx = TokenAssociateTransaction.init()

        let tx2 = tx.tokenIds([try TokenId.fromString("0.0.123")])

        XCTAssertEqual(tx2.tokenIds, [try TokenId.fromString("0.0.123")])
    }
}
