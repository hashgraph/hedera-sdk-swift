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

internal final class EthereumTransactionTests: XCTestCase {
    internal static let unusedPrivateKey: PrivateKey =
        "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

    private static func createTransaction() throws -> EthereumTransaction {
        try EthereumTransaction()
            .nodeAccountIds([5005, 5006])
            .transactionId(
                TransactionId(
                    accountId: 5006,
                    validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0)
                )
            )
            .ethereumData("livestock".data(using: .utf8)!)
            .callDataFileId(FileId.fromString("4.5.6"))
            .maxGasAllowanceHbar(Hbar.fromString("3"))
            .maxTransactionFee(Hbar(1))
            .freeze()
            .sign(unusedPrivateKey)
    }

    internal func testSerialize() throws {
        assertSnapshot(matching: try Self.createTransaction().makeProtoBody(), as: .description)
    }

    internal func testToFromBytes() throws {
        let tx = try Self.createTransaction()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }
}
