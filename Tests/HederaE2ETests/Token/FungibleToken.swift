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

internal struct FungibleToken {
    internal let id: TokenId
    internal let owner: Account

    internal static func create(
        _ testEnv: NonfreeTestEnvironment,
        owner: Account,
        initialSupply: UInt64 = 0
    ) async throws -> Self {
        let ownerKey = Key.single(owner.key.publicKey)
        let receipt = try await TokenCreateTransaction(
            name: "ffff",
            symbol: "f",
            decimals: 3,
            initialSupply: initialSupply,
            treasuryAccountId: owner.id,
            adminKey: ownerKey,
            kycKey: ownerKey,
            freezeKey: ownerKey,
            wipeKey: ownerKey,
            supplyKey: ownerKey,
            freezeDefault: false,
            expirationTime: .now + .minutes(5),
            feeScheduleKey: ownerKey
        )
        .sign(owner.key)
        .execute(testEnv.client)
        .getReceipt(testEnv.client)

        let id = try XCTUnwrap(receipt.tokenId)

        return Self(id: id, owner: owner)
    }

    internal func burn(_ testEnv: NonfreeTestEnvironment, supply amount: UInt64) async throws {
        _ = try await TokenBurnTransaction(tokenId: id, amount: amount)
            .sign(owner.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
    }

    internal func delete(_ testEnv: NonfreeTestEnvironment) async throws {
        _ = try await TokenDeleteTransaction(tokenId: id)
            .sign(owner.key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
    }
}
