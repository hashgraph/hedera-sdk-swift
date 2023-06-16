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

import Hedera
import XCTest

internal final class FileInfo: XCTestCase {
    internal func testQuery() async throws {
        let testEnv = try TestEnvironment.nonFree

        let file = try await File.forContent("[swift::e2e::fileInfo::1]", testEnv)

        addTeardownBlock {
            try await file.delete(testEnv)
        }

        let info = try await FileInfoQuery(fileId: file.fileId).execute(testEnv.client)

        XCTAssertEqual(info.fileId, file.fileId)
        XCTAssertEqual(info.size, 25)
        XCTAssertFalse(info.isDeleted)
        XCTAssertEqual(info.keys, [.single(testEnv.operator.privateKey.publicKey)])
    }

    internal func testQueryEmptyNoAdminKey() async throws {
        let testEnv = try TestEnvironment.nonFree

        let receipt = try await FileCreateTransaction()
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let fileId = try XCTUnwrap(receipt.fileId)

        let info = try await FileInfoQuery(fileId: fileId).execute(testEnv.client)

        XCTAssertEqual(info.fileId, fileId)
        XCTAssertEqual(info.size, 0)
        XCTAssertFalse(info.isDeleted)
        XCTAssertEqual(info.keys, [])
    }

    internal func testQueryCostBigMax() async throws {
        let testEnv = try TestEnvironment.nonFree

        let file = try await File.forContent("[swift::e2e::fileInfo::2]", testEnv)

        addTeardownBlock {
            try await file.delete(testEnv)
        }

        let query = FileInfoQuery(fileId: file.fileId).maxPaymentAmount(Hbar(1000))

        let cost = try await query.getCost(testEnv.client)

        _ = try await query.paymentAmount(cost).execute(testEnv.client)
    }

    internal func testQueryCostSmallMaxFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let file = try await File.forContent("[swift::e2e::fileInfo::3]", testEnv)

        addTeardownBlock {
            try await file.delete(testEnv)
        }

        let query = FileInfoQuery().fileId(file.fileId).maxPaymentAmount(.fromTinybars(1))

        let cost = try await query.getCost(testEnv.client)

        await assertThrowsHErrorAsync(
            try await query.execute(testEnv.client),
            "expected error querying contract"
        ) { error in
            // note: there's a very small chance this fails if the cost of a FileContentsQuery changes right when we execute it.
            XCTAssertEqual(error.kind, .maxQueryPaymentExceeded(queryCost: cost, maxQueryPayment: .fromTinybars(1)))
        }
    }

    internal func testQueryCostInsufficientTxFeeFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let file = try await File.forContent("[swift::e2e::fileInfo::4]", testEnv)

        addTeardownBlock {
            try await file.delete(testEnv)
        }

        await assertThrowsHErrorAsync(
            try await FileInfoQuery()
                .fileId(file.fileId)
                .maxPaymentAmount(.fromTinybars(10000))
                .paymentAmount(.fromTinybars(1))
                .execute(testEnv.client)
        ) { error in
            guard case .queryPaymentPreCheckStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.queryPaymentPreCheckStatus`")
                return
            }

            XCTAssertEqual(status, .insufficientTxFee)
        }
    }
}
