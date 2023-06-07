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

internal final class AccountDelete: XCTestCase {
    internal func testCreateThenDelete() async throws {
        let testEnv = try TestEnvironment.nonFree

        let key = PrivateKey.generateEd25519()

        let receipt = try await AccountCreateTransaction()
            .key(.single(key.publicKey))
            .initialBalance(1)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        _ = try await AccountDeleteTransaction()
            .transferAccountId(testEnv.operator.accountId)
            .accountId(accountId)
            .sign(key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        do {
            _ = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)
            XCTFail()
        } catch let error as HError {
            guard case .queryNoPaymentPreCheckStatus(status: .accountDeleted) = error.kind
            else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }

    internal func testMissingAccountIdFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        do {
            _ = try await AccountDeleteTransaction()
                .transferAccountId(testEnv.operator.accountId)
                .execute(testEnv.client)

            XCTFail()
        } catch let error as HError {
            guard case .transactionPreCheckStatus(status: .accountIDDoesNotExist, transactionId: _) = error.kind
            else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }

    internal func testMissingDeleteeSignatureFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let account = try await Account.create(testEnv)

        // note: this is still useful because the intent is that the next transaction fails.
        addTeardownBlock {
            try await account.delete(testEnv)
        }

        do {
            _ = try await AccountDeleteTransaction()
                .transferAccountId(testEnv.operator.accountId)
                .accountId(account.id)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)

            XCTFail()
        } catch let error as HError {
            guard case .receiptStatus(status: .invalidSignature, transactionId: _) = error.kind
            else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }
}
