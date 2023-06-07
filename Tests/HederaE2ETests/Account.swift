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
