// SPDX-License-Identifier: Apache-2.0

import Hedera
import XCTest

internal class TransactionReceipt: XCTestCase {
    internal func testQuery() async throws {
        let testEnv = try TestEnvironment.nonFree

        let resp = try await TopicCreateTransaction()
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .topicMemo("[e2e::TransactionReceipt]")
            .execute(testEnv.client)

        let txId = try XCTUnwrap(resp.transactionId)

        let _ = try await TransactionReceiptQuery()
            .transactionId(txId)
            .execute(testEnv.client)
    }

    internal func testQueryInvalidTxIdFails() async throws {
        let testEnv = try TestEnvironment.nonFree
        await assertThrowsHErrorAsync(
            try await TransactionReceiptQuery()
                .execute(testEnv.client)
        ) { error in
            guard case .queryNoPaymentPreCheckStatus(let status) = error.kind else {
                XCTFail("`\(error.kind)` is not `.queryNoPaymentPreCheckStatus`")
                return
            }

            XCTAssertEqual(status, .invalidTransactionID)
        }
    }
}
