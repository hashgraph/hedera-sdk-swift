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

internal class ScheduleCreate: XCTestCase {
    // none of these commented out ones are implemented on Hedera's side.
    // internal func testCreateAccount() async throws {
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
    // }

    // internal func testCreateAccountSchedule() async throws {
    //     let testEnv = try TestEnvironment.nonFree

    //     let key = PrivateKey.generateEd25519()

    //     let receipt = try await AccountCreateTransaction()
    //         .key(.single(key.publicKey))
    //         .schedule()
    //         .adminKey(.single(testEnv.operator.privateKey.publicKey))
    //         .payerAccountId(testEnv.operator.accountId)
    //         .execute(testEnv.client)
    //         .getReceipt(testEnv.client)

    //     let scheduleId = try XCTUnwrap(receipt.scheduleId)

    //     let info = try await ScheduleInfoQuery(scheduleId: scheduleId).execute(testEnv.client)

    //     _ = try XCTUnwrap(info.executedAt)
    //     _ = try info.scheduledTransaction
    // }

    internal func testTransfer() async throws {
        let testEnv = try TestEnvironment.nonFree

        let key1 = PrivateKey.generateEd25519()
        let key2 = PrivateKey.generateEd25519()
        let key3 = PrivateKey.generateEd25519()

        let keyList: KeyList = [.single(key1.publicKey), .single(key2.publicKey), .single(key3.publicKey)]

        // Create the account with the `KeyList`
        let transaction = AccountCreateTransaction()
        let accountReceipt =
            try await transaction
            .key(.keyList(keyList))
            .initialBalance(Hbar(1))
            .execute(testEnv.client)

            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(accountReceipt.accountId)

        // Create a transfer transaction with 2/3 signatures.
        let transfer = TransferTransaction().hbarTransfer(accountId, Hbar(-1)).hbarTransfer(
            testEnv.operator.accountId, Hbar(1))

        // Schedule the transactoin
        let scheduled = transfer.schedule()

        let receipt = try await scheduled.execute(testEnv.client).getReceipt(testEnv.client)

        // Get the schedule ID from the receipt
        let scheduleId = try XCTUnwrap(receipt.scheduleId)

        do {
            // Get the schedule info to see if `signatories` is populated with 2/3 signatures
            let info = try await ScheduleInfoQuery(scheduleId: scheduleId).execute(testEnv.client)
            XCTAssertNil(info.executedAt)
        }

        // Finally send this last signature to Hedera. This last signature _should_ mean the transaction executes
        // since all 3 signatures have been provided.
        _ = try await ScheduleSignTransaction()
            .scheduleId(scheduleId)
            .sign(key1)
            .sign(key2)
            .sign(key3)
            .execute(testEnv.client)

            .getReceipt(testEnv.client)

        let info = try await ScheduleInfoQuery(scheduleId: scheduleId).execute(testEnv.client)

        _ = try XCTUnwrap(info.executedAt)

        _ = try await AccountDeleteTransaction()
            .accountId(accountId)
            .transferAccountId(testEnv.operator.accountId)
            .sign(key1)
            .sign(key2)
            .sign(key3)
            .execute(testEnv.client)

            .getReceipt(testEnv.client)
    }

    // token balances are deprecated.
    // internal func testCanScheduleTokenTransfer() async throws {}

    internal func testDoubleScheduleFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let account = try await makeAccount(testEnv, balance: 1)

        let receipt1 = try await TransferTransaction()
            .hbarTransfer(testEnv.operator.accountId, Hbar(-1))
            .hbarTransfer(account.id, Hbar(1))
            .schedule()
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let scheduleId1 = try XCTUnwrap(receipt1.scheduleId)

        let info1 = try await ScheduleInfoQuery(scheduleId: scheduleId1).execute(testEnv.client)

        _ = try XCTUnwrap(info1.executedAt)

        let transfer = TransferTransaction()

        transfer.hbarTransfer(testEnv.operator.accountId, Hbar(-1)).hbarTransfer(account.id, Hbar(1))

        await assertThrowsHErrorAsync(
            try await transfer.schedule().execute(testEnv.client).getReceipt(testEnv.client),
            "expected topic delete to fail"
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .identicalScheduleAlreadyCreated)
        }

    }

    internal func testTopicMessage() async throws {
        let testEnv = try TestEnvironment.nonFree

        // This is the submit key
        let key = PrivateKey.generateEd25519()

        let topicReceipt = try await TopicCreateTransaction()
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .autoRenewAccountId(testEnv.operator.accountId)
            .topicMemo("HCS Topic_")
            .submitKey(.single(key.publicKey))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let topicId = try XCTUnwrap(topicReceipt.topicId)

        let transaction = TopicMessageSubmitTransaction()
            .topicId(topicId)
            .message("scheduled hcs message".data(using: .utf8)!)

        // create schedule
        let receipt =
            try await transaction
            .schedule()
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .payerAccountId(testEnv.operator.accountId)
            .scheduleMemo(
                "mirror scheduled E2E signature on create and sign_\(Date())"
            )
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let scheduleId = try XCTUnwrap(receipt.scheduleId)

        do {
            let info = try await ScheduleInfoQuery(scheduleId: scheduleId).execute(testEnv.client)

            XCTAssertEqual(info.scheduleId, scheduleId)
        }

        _ = try await ScheduleSignTransaction()
            .scheduleId(scheduleId)
            .sign(key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let info = try await ScheduleInfoQuery(scheduleId: scheduleId).execute(testEnv.client)

        _ = try XCTUnwrap(info.executedAt)
    }
}
