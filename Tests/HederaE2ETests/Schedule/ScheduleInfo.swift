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

internal class ScheduleInfo: XCTestCase {
    // not implemented on hedera's part.
    // internal func testAccountCreate() async throws {
    //     let testEnv = try TestEnvironment.nonFree

    //     let key = PrivateKey.generateEd25519()

    //     let transaction = AccountCreateTransaction().key(.single(key.publicKey))

    //     let receipt = try await ScheduleCreateTransaction()
    //         .scheduledTransaction(transaction)
    //         .adminKey(.single(testEnv.operator.privateKey.publicKey))
    //         .payerAccountId(testEnv.operator.accountId)
    //         .execute(testEnv.client)
    //         .getReceipt(testEnv.client)

    //     let scheduleId = try XCTUnwrap(receipt.scheduleId)

    //     let info = try await ScheduleInfoQuery(scheduleId: scheduleId).execute(testEnv.client)

    //     _ = try XCTUnwrap(info.executedAt)

    //     _ = try info.scheduledTransaction
    // }

    internal func testQuery() async throws {
        let testEnv = try TestEnvironment.nonFree

        let account = try await makeAccount(testEnv, balance: 1)

        let receipt = try await TransferTransaction()
            .hbarTransfer(account.id, Hbar(-1))
            .hbarTransfer(testEnv.operator.accountId, Hbar(1))
            .schedule()
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let scheduleId = try XCTUnwrap(receipt.scheduleId)

        let info = try await ScheduleInfoQuery(scheduleId: scheduleId).execute(testEnv.client)

        XCTAssertEqual(info.adminKey, nil)
        XCTAssertEqual(info.creatorAccountId, testEnv.operator.accountId)
        XCTAssertNil(info.deletedAt)
        XCTAssertNil(info.executedAt)
        XCTAssertNotNil(info.expirationTime)
        XCTAssertEqual(info.ledgerId, testEnv.client.ledgerId)
        XCTAssertEqual(info.memo, "")
        XCTAssertEqual(info.payerAccountId, testEnv.operator.accountId)
        _ = try info.scheduledTransaction
        XCTAssertEqual(info.signatories, [])
        XCTAssertFalse(info.waitForExpiry)
    }

    internal func testMissingScheduleIdFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        await assertThrowsHErrorAsync(
            try await ScheduleInfoQuery()
                .execute(testEnv.client)
        ) { error in
            guard case .queryNoPaymentPreCheckStatus(let status) = error.kind else {
                XCTFail("`\(error.kind)` is not `.queryPaymentPreCheckStatus`")
                return
            }

            XCTAssertEqual(status, .invalidScheduleID)
        }
    }

    internal func testQueryCost() async throws {
        let testEnv = try TestEnvironment.nonFree

        let account = try await makeAccount(testEnv, balance: 1)

        let receipt = try await TransferTransaction()
            .hbarTransfer(account.id, Hbar(-1))
            .hbarTransfer(testEnv.operator.accountId, Hbar(1))
            .schedule()
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let scheduleId = try XCTUnwrap(receipt.scheduleId)

        let query = ScheduleInfoQuery(scheduleId: scheduleId)

        let cost = try await query.getCost(testEnv.client)

        _ = try await query.paymentAmount(cost).execute(testEnv.client)
    }

    internal func testQueryCostBigMax() async throws {
        let testEnv = try TestEnvironment.nonFree

        let account = try await makeAccount(testEnv, balance: 1)

        let receipt = try await TransferTransaction()
            .hbarTransfer(account.id, Hbar(-1))
            .hbarTransfer(testEnv.operator.accountId, Hbar(1))
            .schedule()
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let scheduleId = try XCTUnwrap(receipt.scheduleId)

        let query = ScheduleInfoQuery(scheduleId: scheduleId).maxPaymentAmount(Hbar(1000))

        let cost = try await query.getCost(testEnv.client)

        _ = try await query.paymentAmount(cost).execute(testEnv.client)
    }

    internal func testQueryCostSmallMaxFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let account = try await makeAccount(testEnv, balance: 1)

        let receipt = try await TransferTransaction()
            .hbarTransfer(account.id, Hbar(-1))
            .hbarTransfer(testEnv.operator.accountId, Hbar(1))
            .schedule()
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let scheduleId = try XCTUnwrap(receipt.scheduleId)

        let query = ScheduleInfoQuery(scheduleId: scheduleId).maxPaymentAmount(.fromTinybars(1))

        let cost = try await query.getCost(testEnv.client)

        await assertThrowsHErrorAsync(
            try await query.execute(testEnv.client)
        ) { error in
            // note: there's a very small chance this fails if the cost of a FileContentsQuery changes right when we execute it.
            XCTAssertEqual(error.kind, .maxQueryPaymentExceeded(queryCost: cost, maxQueryPayment: .fromTinybars(1)))
        }
    }

    internal func testQueryCostInsufficientTxFeeFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let account = try await makeAccount(testEnv, balance: 1)

        let receipt = try await TransferTransaction()
            .hbarTransfer(account.id, Hbar(-1))
            .hbarTransfer(testEnv.operator.accountId, Hbar(1))
            .schedule()
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let scheduleId = try XCTUnwrap(receipt.scheduleId)

        await assertThrowsHErrorAsync(
            try await ScheduleInfoQuery()
                .scheduleId(scheduleId)
                .maxPaymentAmount(.fromTinybars(10000))
                .paymentAmount(.fromTinybars(1))
                .execute(testEnv.client)
        ) { error in
            guard case .queryPaymentPreCheckStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.queryNoPaymentPreCheckStatus`")
                return
            }

            XCTAssertEqual(status, .insufficientTxFee)
        }
    }
}
