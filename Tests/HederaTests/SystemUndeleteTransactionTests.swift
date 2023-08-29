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

internal final class SystemUndeleteTransactionTests: XCTestCase {
    internal static func makeTransactionFile() throws -> SystemUndeleteTransaction {
        try SystemUndeleteTransaction()
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .fileId(444)
            .freeze()
    }

    internal static func makeTransactionContract() throws -> SystemUndeleteTransaction {
        try SystemUndeleteTransaction()
            .nodeAccountIds(Resources.nodeAccountIds)
            .transactionId(Resources.txId)
            .sign(Resources.privateKey)
            .contractId(444)
            .freeze()
    }

    internal func testSerializeFile() throws {
        let tx = try Self.makeTransactionFile().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytesFile() throws {
        let tx = try Self.makeTransactionFile()

        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testSerializeContract() throws {
        let tx = try Self.makeTransactionContract().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytesContract() throws {
        let tx = try Self.makeTransactionContract()

        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }

    internal func testGetSetFileId() {
        let tx = SystemUndeleteTransaction()
        tx.fileId(444)

        XCTAssertEqual(tx.fileId, 444)
    }

    internal func testGetSetContractId() throws {
        let tx = SystemUndeleteTransaction()
        tx.contractId(444)

        XCTAssertEqual(tx.contractId, 444)
    }
}
