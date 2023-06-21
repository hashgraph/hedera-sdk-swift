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

internal final class AccountUpdate: XCTestCase {
    internal func testSetKey() async throws {
        let testEnv = try TestEnvironment.nonFree

        let key1 = PrivateKey.generateEd25519()
        let key2 = PrivateKey.generateEd25519()

        let receipt = try await AccountCreateTransaction()
            .key(.single(key1.publicKey))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        addTeardownBlock {
            // need a teardown block that signs with both keys because we don't know when this block is executed.
            // it could be executed right now, or after the update succeeds.
            _ = try await AccountDeleteTransaction()
                .accountId(accountId)
                .transferAccountId(testEnv.operator.accountId)
                .sign(key1)
                .sign(key2)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
        }

        do {
            let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

            XCTAssertEqual(info.key, .single(key1.publicKey))

            _ = try await AccountUpdateTransaction()
                .accountId(accountId)
                .key(.single(key2.publicKey))
                .sign(key1)
                .sign(key2)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
        }

        let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

        XCTAssertEqual(info.accountId, accountId)
        XCTAssertFalse(info.isDeleted)
        XCTAssertEqual(info.key, .single(key2.publicKey))
        XCTAssertEqual(info.balance, 0)
        XCTAssertEqual(info.autoRenewPeriod, .days(90))
        // fixme: ensure no warning gets emitted.
        // XCTAssertNil(info.proxyAccountId)
        XCTAssertEqual(info.proxyReceived, 0)

    }

    internal func testMissingAccountIdFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        await assertThrowsHErrorAsync(
            try await AccountUpdateTransaction().execute(testEnv.client).getReceipt(testEnv.client)
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .accountIDDoesNotExist)
        }
    }
}
