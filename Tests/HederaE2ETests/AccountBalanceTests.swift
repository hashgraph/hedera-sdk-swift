import Hedera
import XCTest

internal final class AccountBalance: XCTestCase {
    internal func testQuery() async throws {
        let testEnv = TestEnvironment.global

        guard let op = testEnv.operator else {
            throw XCTSkip("skipping due to lack of operator")
        }

        let balance = try await AccountBalanceQuery(accountId: op.accountId).execute(testEnv.client)

        // log::trace!("successfully queried balance: {balance:?}");

        XCTAssertEqual(balance.accountId, op.accountId)
        XCTAssertGreaterThan(balance.hbars, 0)
    }

    internal func testQueryCost() async throws {
        let testEnv = TestEnvironment.global

        guard let op = testEnv.operator else {
            throw XCTSkip("skipping due to lack of operator")
        }

        let query = AccountBalanceQuery()

        query.accountId(op.accountId).maxPaymentAmount(1)

        let cost = try await query.getCost(testEnv.client)

        XCTAssertEqual(cost, 0)

        let balance = try await query.paymentAmount(cost).execute(testEnv.client)

        XCTAssertEqual(balance.accountId, op.accountId)
        XCTAssertGreaterThan(balance.hbars, 0)
    }

    internal func testQueryCostBigMax() async throws {
        let testEnv = TestEnvironment.global

        guard let op = testEnv.operator else {
            throw XCTSkip("skipping due to lack of operator")
        }

        let query = AccountBalanceQuery()

        query.accountId(op.accountId).maxPaymentAmount(1_000_000)

        let cost = try await query.getCost(testEnv.client)

        XCTAssertEqual(cost, 0)

        let balance = try await query.paymentAmount(cost).execute(testEnv.client)

        XCTAssertEqual(balance.accountId, op.accountId)
        XCTAssertGreaterThan(balance.hbars, 0)
    }

    internal func testQueryCostSmallMax() async throws {
        let testEnv = TestEnvironment.global

        guard let op = testEnv.operator else {
            throw XCTSkip("skipping due to lack of operator")
        }

        let query = AccountBalanceQuery()

        query.accountId(op.accountId).maxPaymentAmount(.fromTinybars(1))

        let cost = try await query.getCost(testEnv.client)

        XCTAssertEqual(cost, 0)

        let balance = try await query.paymentAmount(cost).execute(testEnv.client)

        XCTAssertEqual(balance.accountId, op.accountId)
        XCTAssertGreaterThan(balance.hbars, 0)
    }

    internal func testInvalidAccountIdFails() async throws {
        let testEnv = TestEnvironment.global

        do {
            _ = try await AccountBalanceQuery(accountId: "1.0.3").execute(testEnv.client)

            XCTFail("expected error querying account balance")
            return
        } catch let error as HError {
            guard case .queryNoPaymentPreCheckStatus(status: .invalidAccountID) = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }

    // disabled because swift doesn't have a way to ignore deprecated warnings.
    // internal func testQueryTokenBalances() async throws {
    //     let testEnv = try TestEnvironment.nonFree

    //     let account = try await Account.create(testEnv, balance: 10)

    //     addTeardownBlock { try await account.delete(testEnv) }

    //     let receipt = try await TokenCreateTransaction()
    //         .name("ffff")
    //         .symbol("f")
    //         .initialSupply(10000)
    //         .decimals(50)
    //         .treasuryAccountId(account.id)
    //         .expirationTime(.now + .minutes(5))
    //         .adminKey(.single(account.key.publicKey))
    //         .supplyKey(.single(account.key.publicKey))
    //         .freezeDefault(false)
    //         .sign(account.key)
    //         .execute(testEnv.client)
    //         .getReceipt(testEnv.client)

    //     let tokenId = try XCTUnwrap(receipt.tokenId)

    //     addTeardownBlock {
    //         _ = try await TokenBurnTransaction()
    //             .tokenId(tokenId)
    //             .amount(10000)
    //             .sign(account.key)
    //             .execute(testEnv.client)
    //             .getReceipt(testEnv.client)

    //         _ = try await TokenDeleteTransaction()
    //             .tokenId(tokenId)
    //             .sign(account.key)
    //             .execute(testEnv.client)
    //             .getReceipt(testEnv.client)
    //     }

    //     let _ = try await AccountBalanceQuery().accountId(account.id).execute(testEnv.client)

    //     // XCTAssertEqual(balance.tokenBalances[tokenId], 10000)
    //     // XCTAssertEqual(balance.tokenDecimals[tokenId], 50)
    // }
}
