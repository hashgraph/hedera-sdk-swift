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

internal final class TokenUpdate: XCTestCase {
    internal func testBasic() async throws {
        let testEnv = try TestEnvironment.nonFree

        let account = try await makeAccount(testEnv)

        let token = try await FungibleToken.create(testEnv, owner: account)

        addTeardownBlock {
            try await token.delete(testEnv)
        }

        _ = try await TokenUpdateTransaction(tokenId: token.id, tokenName: "aaaa", tokenSymbol: "A")
            .sign(account.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let info = try await TokenInfoQuery(tokenId: token.id).execute(testEnv.client)

        XCTAssertEqual(info.tokenId, token.id)
        XCTAssertEqual(info.name, "aaaa")
        XCTAssertEqual(info.symbol, "A")
        XCTAssertEqual(info.decimals, 3)
        XCTAssertEqual(info.treasuryAccountId, account.id)
        XCTAssertEqual(info.adminKey, .single(account.key.publicKey))
        XCTAssertEqual(info.freezeKey, .single(account.key.publicKey))
        XCTAssertEqual(info.wipeKey, .single(account.key.publicKey))
        XCTAssertEqual(info.kycKey, .single(account.key.publicKey))
        XCTAssertEqual(info.supplyKey, .single(account.key.publicKey))
        XCTAssertEqual(info.defaultFreezeStatus, false)
        XCTAssertEqual(info.defaultKycStatus, false)
    }

    internal func testImmutableTokenFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        // can't delete the account because the token still exists, can't delete the token because there's no admin key.
        let account = try await Account.create(testEnv)

        let receipt = try await TokenCreateTransaction(
            name: "ffff",
            symbol: "F",
            treasuryAccountId: account.id,
            freezeDefault: false,
            expirationTime: .now + .minutes(5)
        )
        .sign(account.key)
        .execute(testEnv.client)
        .getReceipt(testEnv.client)

        let tokenId = try XCTUnwrap(receipt.tokenId)

        await assertThrowsHErrorAsync(
            try await TokenUpdateTransaction(tokenId: tokenId, tokenName: "aaaa", tokenSymbol: "A")
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .tokenIsImmutable)
        }
    }
}
