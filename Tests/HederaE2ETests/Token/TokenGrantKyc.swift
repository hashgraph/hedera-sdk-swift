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

internal class TokenGrantKyc: XCTestCase {
    internal func testBasic() async throws {
        let testEnv = try TestEnvironment.nonFree

        async let alice = makeAccount(testEnv)
        async let bob = makeAccount(testEnv)

        let token = try await FungibleToken.create(testEnv, owner: alice)

        addTeardownBlock {
            try await token.delete(testEnv)
        }

        _ = try await TokenAssociateTransaction(accountId: bob.id, tokenIds: [token.id])
            .sign(bob.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        _ = try await TokenGrantKycTransaction(accountId: bob.id, tokenId: token.id)
            .sign(alice.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
    }

    internal func testMissingTokenId() async throws {
        let testEnv = try TestEnvironment.nonFree

        await assertThrowsHErrorAsync(
            try await TokenGrantKycTransaction(accountId: testEnv.operator.accountId)
                .execute(testEnv.client)
                .getReceipt(testEnv.client),
            "expected error granting kyc"
        ) { error in
            guard case .transactionPreCheckStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.transactionPreCheckStatus`")
                return
            }

            XCTAssertEqual(status, .invalidTokenID)
        }

    }

    internal func testMissingAccountIdFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        async let account = makeAccount(testEnv)

        let token = try await FungibleToken.create(testEnv, owner: account)

        addTeardownBlock {
            try await token.delete(testEnv)
        }

        await assertThrowsHErrorAsync(
            try await TokenGrantKycTransaction(tokenId: token.id).execute(testEnv.client),
            "expected error granting kyc"
        ) { error in
            guard case .transactionPreCheckStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.transactionPreCheckStatus`")
                return
            }

            XCTAssertEqual(status, .invalidAccountID)
        }
    }

    internal func testUnassociatedTokenFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        async let alice = makeAccount(testEnv)
        async let bobFut = makeAccount(testEnv)

        let token = try await FungibleToken.create(testEnv, owner: alice)

        addTeardownBlock {
            try await token.delete(testEnv)
        }

        let bob = try await bobFut

        await assertThrowsHErrorAsync(
            try await TokenGrantKycTransaction(accountId: bob.id, tokenId: token.id)
                .sign(token.owner.key)
                .execute(testEnv.client)
                .getReceipt(testEnv.client),
            "expected error granting kyc"
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .tokenNotAssociatedToAccount)
        }
    }
}
