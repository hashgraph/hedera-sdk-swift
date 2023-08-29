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

internal final class ContractUpdateTransactionTests: XCTestCase {
    private static func updateTransaction() throws -> ContractUpdateTransaction {
        try ContractUpdateTransaction()
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .contractId("0.0.5007")
            .adminKey(.single(Resources.publicKey))
            .maxAutomaticTokenAssociations(101)
            .autoRenewPeriod(.days(1))
            .contractMemo("3")
            .stakedAccountId("0.0.3")
            .expirationTime(Timestamp(seconds: 1_554_158_543, subSecondNanos: 0))
            .proxyAccountId(AccountId(4))
            .maxTransactionFee(.fromTinybars(100_000))
            .autoRenewAccountId(AccountId(30))
            .freeze()
    }

    private static func updateTransaction2() throws -> ContractUpdateTransaction {
        try ContractUpdateTransaction()
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .contractId(ContractId(5007))
            .adminKey(.single(Resources.publicKey))
            .maxAutomaticTokenAssociations(101)
            .autoRenewPeriod(.days(1))
            .contractMemo("3")
            .stakedNodeId(4)
            .expirationTime(.init(seconds: 1_554_158_543, subSecondNanos: 0))
            .proxyAccountId(AccountId(4))
            .maxTransactionFee(.fromTinybars(100_000))
            .autoRenewAccountId(AccountId(30))
            .freeze()
    }

    internal func testSerialize() throws {
        let tx = try Self.updateTransaction().toProtobuf()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testSerialize2() throws {
        let tx = try Self.updateTransaction2().toProtobuf()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytes() throws {
        let tx = try Self.updateTransaction()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testToFromBytes2() throws {
        let tx = try Self.updateTransaction2()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }
}
