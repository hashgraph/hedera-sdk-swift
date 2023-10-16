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

internal final class SignatureTests: XCTestCase {
    internal static var firstPrivateKey: PrivateKey =
        "302e020100300506032b657004220420e40d4241d093b22910c78135e0501b137cd9205bbb9c0153c5adf2c65e7dc95a"
    internal static var secondPrivateKey: PrivateKey =
        "302e020100300506032b657004220420e40d4241d093b22910c78135e0501b137cd9205bbb9c0153c5adf2c65e7dc85b"

    internal func testGetSignatures() throws {
        let new = TransferTransaction()

        let bodyBytes = try new.maxTransactionFee(10).transactionValidDuration(Duration.seconds(119))
            .transactionMemo("Frosted flakes").hbarTransfer(AccountId(2), 2).hbarTransfer(AccountId(101), -2)
            .transactionId(Resources.txId).nodeAccountIds(Resources.nodeAccountIds).freeze().sign(Self.firstPrivateKey)
            .sign(Self.secondPrivateKey)
            .toBytes()

        let tx2 = try Transaction.fromBytes(bodyBytes)

        XCTAssertEqual(try tx2.getSignatures().count, 2)
    }

    internal func testGetAllSignaturesFromChunked() throws {
        let client = Client.forTestnet()
        client.setOperator(0, .generateEd25519())

        let transactionId = TransactionId(accountId: 0, validStart: .now)

        let tx = try TopicMessageSubmitTransaction()
            .topicId(314)
            .message("Meep!".data(using: .utf8)!)
            .chunkSize(8)
            .maxChunks(2)
            .transactionId(transactionId)
            .freezeWith(client)

        XCTAssertEqual(try tx.getAllSignatures().count, 1)
    }
}
