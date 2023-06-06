import Hedera
import XCTest

internal final class AccountCreateE2ETests: XCTestCase {
    internal func testInitialBalanceAndKey() async throws {
        let testEnv = try TestEnvironment.nonFree

        let key = PrivateKey.generateEd25519()

        let receipt = try await AccountCreateTransaction()
            .key(.single(key.publicKey))
            .initialBalance(Hbar(1))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        addTeardownBlock {
            _ = try await AccountDeleteTransaction()
                .accountId(accountId)
                .transferAccountId(testEnv.config.operator.accountId)
                .sign(key)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)
        }

        let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

        XCTAssertEqual(info.accountId, accountId)
        XCTAssertFalse(info.isDeleted)
        XCTAssertEqual(info.key, .single(key.publicKey))
        XCTAssertEqual(info.balance, 1)
        XCTAssertEqual(info.autoRenewPeriod, .days(90))
        // fixme: ensure no warning gets emitted.
        // XCTAssertNil(info.proxyAccountId)
        XCTAssertEqual(info.proxyReceived, 0)
    }
}
