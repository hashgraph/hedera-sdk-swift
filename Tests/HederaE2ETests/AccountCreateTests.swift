import Hedera
import XCTest

internal final class AccountCreate: XCTestCase {
    private static func teardownDeleteAccount(_ testEnv: NonfreeTestEnvironment, accountId: AccountId, key: PrivateKey)
        async throws
    {
        _ = try await AccountDeleteTransaction()
            .accountId(accountId)
            .transferAccountId(testEnv.operator.accountId)
            .sign(key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)
    }

    internal func testInitialBalanceAndKey() async throws {
        let testEnv = try TestEnvironment.nonFree

        let key = PrivateKey.generateEd25519()

        let receipt = try await AccountCreateTransaction()
            .key(.single(key.publicKey))
            .initialBalance(Hbar(1))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        addTeardownBlock { try await Self.teardownDeleteAccount(testEnv, accountId: accountId, key: key) }

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

    internal func testNoInitialBalance() async throws {
        let testEnv = try TestEnvironment.nonFree

        let key = PrivateKey.generateEd25519()

        let receipt = try await AccountCreateTransaction()
            .key(.single(key.publicKey))
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        addTeardownBlock { try await Self.teardownDeleteAccount(testEnv, accountId: accountId, key: key) }

        let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

        XCTAssertEqual(info.accountId, accountId)
        XCTAssertFalse(info.isDeleted)
        XCTAssertEqual(info.key, .single(key.publicKey))
        XCTAssertEqual(info.balance, 0)
        XCTAssertEqual(info.autoRenewPeriod, .days(90))
        // fixme: ensure no warning gets emitted.
        // XCTAssertNil(info.proxyAccountId)
        XCTAssertEqual(info.proxyReceived, 0)
    }

    internal func testMissingKeyError() async throws {
        let testEnv = try TestEnvironment.nonFree

        do {
            let receipt = try await AccountCreateTransaction()
                .execute(testEnv.client)
                .getReceipt(testEnv.client)

            XCTFail("expected error creating account: \(receipt)")
            return
        } catch let error as HError {
            guard case .transactionPreCheckStatus(status: .keyRequired, transactionId: _) = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }

    internal func testAliasKey() async throws {
        let testEnv = try TestEnvironment.nonFree

        let key = PrivateKey.generateEd25519()

        let aliasId = key.toAccountId(shard: 0, realm: 0)

        _ = try await TransferTransaction()
            .hbarTransfer(testEnv.operator.accountId, "-0.01")
            .hbarTransfer(aliasId, "0.01")
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let info = try await AccountInfoQuery().accountId(aliasId).execute(testEnv.client)

        addTeardownBlock { try await Self.teardownDeleteAccount(testEnv, accountId: info.accountId, key: key) }

        XCTAssertEqual(info.aliasKey, key.publicKey)
    }

    // there's a disagreement between Java and Swift here.
    // internal func testManagesExpiration() async throws {
    //     let testEnv = try TestEnvironment.nonFree

    //     let key = PrivateKey.generateEd25519()

    //     let receipt = try await AccountCreateTransaction()
    //         .key(.single(key.publicKey))
    //         .transactionId(
    //             .withValidStart(
    //                 testEnv.operator.accountId,
    //                 .now - .seconds(40)
    //             )
    //         )
    //         .transactionValidDuration(.seconds(30))
    //         .freezeWith(testEnv.client)
    //         .execute(testEnv.client)
    //         .getReceipt(testEnv.client)

    //     let accountId = try XCTUnwrap(receipt.accountId)

    //     addTeardownBlock { try await Self.teardownDeleteAccount(testEnv, accountId: accountId, key: key) }

    //     let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

    //     XCTAssertEqual(info.accountId, accountId)
    //     XCTAssertFalse(info.isDeleted)
    //     XCTAssertEqual(info.key, .single(key.publicKey))
    //     XCTAssertEqual(info.balance, 0)
    //     XCTAssertEqual(info.autoRenewPeriod, .days(90))
    //     // fixme: ensure no warning gets emitted.
    //     // XCTAssertNil(info.proxyAccountId)
    //     XCTAssertEqual(info.proxyReceived, 0)
    // }

    internal func testAliasFromAdminKey() async throws {
        // Tests the third row of this table
        // https://github.com/hashgraph/hedera-improvement-proposal/blob/d39f740021d7da592524cffeaf1d749803798e9a/HIP/hip-583.md#signatures
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEcdsa()
        let evmAddress = try XCTUnwrap(adminKey.publicKey.toEvmAddress())

        let receipt = try await AccountCreateTransaction()
            .key(.single(adminKey.publicKey))
            // .alias(evmAddress)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        addTeardownBlock { try await Self.teardownDeleteAccount(testEnv, accountId: accountId, key: adminKey) }

        let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

        XCTAssertEqual(info.accountId, accountId)
        XCTAssertEqual("0x\(info.contractAccountId)", evmAddress.toString())
        XCTAssertEqual(info.key, .single(adminKey.publicKey))
    }

    internal func testAliasFromAdminKeyWithReceiverSigRequired() async throws {
        // Tests the fourth row of this table
        // https://github.com/hashgraph/hedera-improvement-proposal/blob/d39f740021d7da592524cffeaf1d749803798e9a/HIP/hip-583.md#signatures
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEcdsa()
        let evmAddress = try XCTUnwrap(adminKey.publicKey.toEvmAddress())

        let receipt = try await AccountCreateTransaction()
            .receiverSignatureRequired(true)
            .key(.single(adminKey.publicKey))
            .alias(evmAddress)
            .freezeWith(testEnv.client)
            .sign(adminKey)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        addTeardownBlock { try await Self.teardownDeleteAccount(testEnv, accountId: accountId, key: adminKey) }

        let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

        XCTAssertEqual(info.accountId, accountId)
        XCTAssertEqual("0x\(info.contractAccountId)", evmAddress.toString())
        XCTAssertEqual(info.key, .single(adminKey.publicKey))
    }

    internal func testAliasFromAdminKeyWithReceiverSigRequiredMissingSignatureFails()
        async throws
    {
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEcdsa()
        let evmAddress = try XCTUnwrap(adminKey.publicKey.toEvmAddress())

        do {
            let receipt = try await AccountCreateTransaction()
                .receiverSignatureRequired(true)
                .key(.single(adminKey.publicKey))
                .alias(evmAddress)
                .freezeWith(testEnv.client)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)

            XCTFail("expected error creating account: \(receipt)")
            return
        } catch let error as HError {
            guard case .receiptStatus(status: .invalidSignature, transactionId: _) = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }

    internal func testAlias() async throws {
        // Tests the fifth row of this table
        // https://github.com/hashgraph/hedera-improvement-proposal/blob/d39f740021d7da592524cffeaf1d749803798e9a/HIP/hip-583.md#signatures
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEd25519()

        let key = PrivateKey.generateEcdsa()
        let evmAddress = try XCTUnwrap(key.publicKey.toEvmAddress())

        let receipt = try await AccountCreateTransaction()
            .key(.single(adminKey.publicKey))
            .alias(evmAddress)
            .freezeWith(testEnv.client)
            .sign(key)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        addTeardownBlock { try await Self.teardownDeleteAccount(testEnv, accountId: accountId, key: adminKey) }

        let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

        XCTAssertEqual(info.accountId, accountId)
        XCTAssertEqual("0x\(info.contractAccountId)", evmAddress.toString())
        XCTAssertEqual(info.key, .single(adminKey.publicKey))
    }

    internal func testAliasMissingSignatureFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEd25519()

        let key = PrivateKey.generateEcdsa()
        let evmAddress = try XCTUnwrap(key.publicKey.toEvmAddress())

        do {
            let receipt = try await AccountCreateTransaction()
                .key(.single(adminKey.publicKey))
                .alias(evmAddress)
                .freezeWith(testEnv.client)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)

            XCTFail("expected error creating account: \(receipt)")
            return
        } catch let error as HError {
            guard case .receiptStatus(status: .invalidSignature, transactionId: _) = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }

    internal func testAliasWithReceiverSigRequired() async throws {
        // Tests the sixth row of this table
        // https://github.com/hashgraph/hedera-improvement-proposal/blob/d39f740021d7da592524cffeaf1d749803798e9a/HIP/hip-583.md#signatures
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEd25519()

        let key = PrivateKey.generateEcdsa()
        let evmAddress = try XCTUnwrap(key.publicKey.toEvmAddress())

        let receipt = try await AccountCreateTransaction()
            .receiverSignatureRequired(true)
            .key(.single(adminKey.publicKey))
            .alias(evmAddress)
            .freezeWith(testEnv.client)
            .sign(key)
            .sign(adminKey)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let accountId = try XCTUnwrap(receipt.accountId)

        addTeardownBlock { try await Self.teardownDeleteAccount(testEnv, accountId: accountId, key: adminKey) }

        let info = try await AccountInfoQuery(accountId: accountId).execute(testEnv.client)

        XCTAssertEqual(info.accountId, accountId)
        XCTAssertEqual("0x\(info.contractAccountId)", evmAddress.toString())
        XCTAssertEqual(info.key, .single(adminKey.publicKey))
    }

    internal func testAliasWithReceiverSigRequiredMissingSignatureFails() async throws {
        let testEnv = try TestEnvironment.nonFree

        let adminKey = PrivateKey.generateEd25519()

        let key = PrivateKey.generateEcdsa()
        let evmAddress = try XCTUnwrap(key.publicKey.toEvmAddress())

        do {
            let receipt = try await AccountCreateTransaction()
                .receiverSignatureRequired(true)
                .key(.single(adminKey.publicKey))
                .alias(evmAddress)
                .freezeWith(testEnv.client)
                .execute(testEnv.client)
                .getReceipt(testEnv.client)

            XCTFail("expected error creating account: \(receipt)")
            return
        } catch let error as HError {
            guard case .receiptStatus(status: .invalidSignature, transactionId: _) = error.kind else {
                XCTFail("incorrect error: \(error)")
                return
            }
        }
    }
}
