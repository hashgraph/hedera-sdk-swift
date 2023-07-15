import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal class AccountAllowanceDeleteTransactionTests: XCTestCase {
    internal static let unusedPrivateKey: PrivateKey =
        "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

    private static func makeTransaction() throws -> AccountAllowanceDeleteTransaction {
        let ownerId: AccountId = "5.6.7"

        let invalidTokenIds: [TokenId] = ["4.4.4", "8.8.8"]

        return try AccountAllowanceDeleteTransaction()
            .nodeAccountIds(["0.0.5005", "0.0.5006"])
            .transactionId(
                TransactionId(
                    accountId: 5006,
                    validStart: Timestamp(seconds: 1_554_158_542, subSecondNanos: 0),
                    scheduled: false
                )
            )
            .deleteAllTokenNftAllowances(invalidTokenIds[0].nft(123), ownerId)
            .deleteAllTokenNftAllowances(invalidTokenIds[0].nft(456), ownerId)
            .deleteAllTokenNftAllowances(invalidTokenIds[1].nft(456), ownerId)
            .deleteAllTokenNftAllowances(invalidTokenIds[0].nft(789), ownerId)
            .maxTransactionFee(Hbar.fromTinybars(100_000))
            .freeze()
            .sign(unusedPrivateKey)
    }

    internal func testSerialize() throws {
        let tx = try Self.makeTransaction().makeProtoBody()

        assertSnapshot(matching: tx, as: .description)
    }

    internal func testToFromBytes() throws {
        let tx = try Self.makeTransaction()
        let tx2 = try Transaction.fromBytes(tx.toBytes())

        XCTAssertEqual(try tx.makeProtoBody(), try tx2.makeProtoBody())
    }
}
