import Hedera
import XCTest

internal final class AccountUpdate: XCTestCase {
    func testSetKey() async throws {
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

    func testMissingAccountIdFails() async throws {
        let testEnv = try TestEnvironment.nonFree
        do {
            let _ = try await AccountUpdateTransaction().execute(testEnv.client).getReceipt(testEnv.client)
            XCTFail()
        } catch let error as HError {
            guard case .receiptStatus(status: Status.accountIDDoesNotExist, transactionId: _) = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }

        }
    }
}
