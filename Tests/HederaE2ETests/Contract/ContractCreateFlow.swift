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

internal final class ContractCreateFlow: XCTestCase {
    internal func testBasic() async throws {
        let testEnv = try TestEnvironment.nonFree

        // hack: we happen to know how many file operations we need.
        do {
            async let slots = (testEnv.ratelimits.file(), testEnv.ratelimits.file())

            _ = try await slots
        }

        let receipt = try await Hedera.ContractCreateFlow()
            .bytecode(ContractHelpers.bytecodeString)
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .gas(100000)
            .constructorParameters(ContractFunctionParameters().addString("Hello from Hedera."))
            .contractMemo("[e2e::ContractCreateFlow]")
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let contractId = try XCTUnwrap(receipt.contractId)

        addTeardownBlock {
            _ = try await ContractDeleteTransaction(contractId: contractId)
                .transferAccountId(testEnv.operator.accountId)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
        }

        let info = try await ContractInfoQuery(contractId: contractId).execute(testEnv.client)

        XCTAssertEqual(info.contractId, contractId)
        XCTAssertEqual(String(describing: info.accountId), String(describing: info.contractId))
        XCTAssertEqual(info.adminKey, .single(testEnv.operator.privateKey.publicKey))
        XCTAssertEqual(info.storage, 128)
        XCTAssertEqual(info.contractMemo, "[e2e::ContractCreateFlow]")
    }

    internal func testAdminKeyMissingSignatureFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEd25519()

        // hack: we happen to know how many file operations we need.
        try await testEnv.ratelimits.file()

        await assertThrowsHErrorAsync(
            try await Hedera.ContractCreateFlow()
                .bytecode(ContractHelpers.bytecodeString)
                .adminKey(.single(adminKey.publicKey))
                .gas(100000)
                .constructorParameters(ContractFunctionParameters().addString("Hello from Hedera."))
                .contractMemo("[e2e::ContractCreateFlow]")
                .execute(testEnv.client)
                .getReceipt(testEnv.client),
            "expected error deleting contract"
        ) { error in
            guard case .receiptStatus(let status, transactionId: _) = error.kind else {
                XCTFail("`\(error.kind)` is not `.receiptStatus`")
                return
            }

            XCTAssertEqual(status, .invalidSignature)
        }
    }

    internal func testAdminKey() async throws {
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEd25519()

        // hack: we happen to know how many file operations we need.
        do {
            async let slots = (testEnv.ratelimits.file(), testEnv.ratelimits.file())

            _ = try await slots
        }

        let receipt = try await Hedera.ContractCreateFlow()
            .bytecode(ContractHelpers.bytecodeString)
            .adminKey(.single(adminKey.publicKey))
            .gas(100000)
            .constructorParameters(ContractFunctionParameters().addString("Hello from Hedera."))
            .contractMemo("[e2e::ContractCreateFlow]")
            .sign(adminKey)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
        let contractId = try XCTUnwrap(receipt.contractId)

        addTeardownBlock {
            _ = try await ContractDeleteTransaction(contractId: contractId)
                .transferAccountId(testEnv.operator.accountId)
                .sign(adminKey)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
        }
        let info = try await ContractInfoQuery(contractId: contractId).execute(testEnv.client)

        XCTAssertEqual(info.contractId, contractId)
        XCTAssertEqual(String(describing: info.accountId), String(describing: info.contractId))
        XCTAssertEqual(info.adminKey, .single(adminKey.publicKey))
        XCTAssertEqual(info.storage, 128)
        XCTAssertEqual(info.contractMemo, "[e2e::ContractCreateFlow]")

    }

    internal func testAdminKeySignWith() async throws {
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEd25519()

        // hack: we happen to know how many file operations we need.
        do {
            async let slots = (testEnv.ratelimits.file(), testEnv.ratelimits.file())

            _ = try await slots
        }

        let receipt = try await Hedera.ContractCreateFlow()
            .bytecode(ContractHelpers.bytecodeString)
            .adminKey(.single(adminKey.publicKey))
            .gas(100000)
            .constructorParameters(ContractFunctionParameters().addString("Hello from Hedera."))
            .contractMemo("[e2e::ContractCreateFlow]")
            .signWith(adminKey.publicKey, adminKey.sign(_:))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
        let contractId = try XCTUnwrap(receipt.contractId)

        addTeardownBlock {
            _ = try await ContractDeleteTransaction(contractId: contractId)
                .transferAccountId(testEnv.operator.accountId)
                .sign(adminKey)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
        }
        let info = try await ContractInfoQuery(contractId: contractId).execute(testEnv.client)

        XCTAssertEqual(info.contractId, contractId)
        XCTAssertEqual(String(describing: info.accountId), String(describing: info.contractId))
        XCTAssertEqual(info.adminKey, .single(adminKey.publicKey))
        XCTAssertEqual(info.storage, 128)
        XCTAssertEqual(info.contractMemo, "[e2e::ContractCreateFlow]")

    }
}
