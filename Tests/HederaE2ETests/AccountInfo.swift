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

internal final class AccountInfo: XCTestCase {
    internal func testQuery() async throws {
        let testEnv = try TestEnvironment.nonFree

        let info = try await AccountInfoQuery(accountId: testEnv.operator.accountId)
            .execute(testEnv.client)

        XCTAssertEqual(info.accountId, testEnv.operator.accountId)
        XCTAssertFalse(info.isDeleted)
        XCTAssertEqual(info.key, .single(testEnv.operator.privateKey.publicKey))
        XCTAssertGreaterThan(info.balance, 0)

        // fixme: ensure no warning gets emitted.
        // XCTAssertNil(info.proxyAccountId)
        XCTAssertEqual(info.proxyReceived, 0)
    }

    internal func testQueryCostForOperator() async throws {
        let testEnv = try TestEnvironment.nonFree

        let query = AccountInfoQuery(accountId: testEnv.operator.accountId)
            .maxPaymentAmount(Hbar(1))

        let cost = try await query.getCost(testEnv.client)

        let info = try await query.paymentAmount(cost).execute(testEnv.client)

        XCTAssertEqual(info.accountId, testEnv.operator.accountId)
    }

    internal func testQueryCostBigMax() async throws {
        let testEnv = try TestEnvironment.nonFree

        let query = AccountInfoQuery(accountId: testEnv.operator.accountId)
            .maxPaymentAmount(.max)

        let cost = try await query.getCost(testEnv.client)

        let info = try await query.paymentAmount(cost).execute(testEnv.client)

        XCTAssertEqual(info.accountId, testEnv.operator.accountId)
    }

    internal func testQueryCostSmallMaxFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let query = AccountInfoQuery(accountId: testEnv.operator.accountId)
            .maxPaymentAmount(.fromTinybars(1))

        let cost = try await query.getCost(testEnv.client)

        do {
            _ = try await query.execute(testEnv.client)
            XCTFail()
        } catch let error as HError {
            // note: there's a very small chance this fails if the cost of a AccountInfoQuery changes right when we execute it.
            guard case .maxQueryPaymentExceeded(cost, .fromTinybars(1)) = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }

        }
    }

    internal func testGetCostInsufficientTxFeeFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        do {
            _ = try await AccountInfoQuery()
                .accountId(testEnv.operator.accountId)
                .maxPaymentAmount(.fromTinybars(10000))
                .paymentAmount(.fromTinybars(1))
                .execute(testEnv.client)

            XCTFail()
        } catch let error as HError {
            guard case .queryPaymentPreCheckStatus(status: .insufficientTxFee, transactionId: _) = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }

    internal func testFlowVerifyTransaction() async throws {
        let testEnv = try TestEnvironment.nonFree

        let newKey = PrivateKey.generateEd25519()
        let newPublicKey = newKey.publicKey

        let signedTx = try AccountCreateTransaction()
            .key(.single(newPublicKey))
            .initialBalance(.fromTinybars(1000))
            .freezeWith(testEnv.client)
            .signWithOperator(testEnv.client)

        let unsignedTx = try AccountCreateTransaction()
            .key(.single(newPublicKey))
            .initialBalance(.fromTinybars(1000))
            .freezeWith(testEnv.client)

        do {
            try await AccountInfoFlow.verifyTransactionSignature(testEnv.client, testEnv.operator.accountId, signedTx)
        } catch {
            XCTFail("Expected `verifyTransactionSignature` to not throw, error: \(error)")
        }

        do {
            try await AccountInfoFlow.verifyTransactionSignature(testEnv.client, testEnv.operator.accountId, unsignedTx)

            XCTFail("Expected `verifyTransactionSignature` to throw")
        } catch let error as HError {
            guard case .signatureVerify = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }

    }
}
