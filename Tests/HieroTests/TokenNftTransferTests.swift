// SPDX-License-Identifier: Apache-2.0

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal class TokenNftTransferTests: XCTestCase {
    internal static let testReceiver = AccountId("0.0.5008")
    internal static let testSerialNumber = 4

    private func makeTransfer() throws -> TokenNftTransfer {
        TokenNftTransfer.init(
            tokenId: Resources.tokenId, sender: Resources.accountId, receiver: Self.testReceiver, serial: 4,
            isApproved: true)
    }

    internal func testSerialize() throws {
        let transfer = try makeTransfer()

        assertSnapshot(of: transfer, as: .description)
    }
}
