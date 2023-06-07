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

internal struct Account {
    internal init(id: AccountId, key: PrivateKey) {
        self.id = id
        self.key = key
    }

    internal static func create(_ testEnv: NonfreeTestEnvironment, balance: Hbar = 0) async throws -> Self {
        let key = PrivateKey.generateEd25519()

        let receipt = try await AccountCreateTransaction(key: .single(key.publicKey), initialBalance: balance)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let id = try XCTUnwrap(receipt.accountId)

        return Self(id: id, key: key)
    }

    internal func delete(_ testEnv: NonfreeTestEnvironment) async throws {
        _ = try await AccountDeleteTransaction()
            .accountId(id)
            .transferAccountId(testEnv.operator.accountId)
            .sign(key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
    }

    internal let id: AccountId
    internal let key: PrivateKey
}
