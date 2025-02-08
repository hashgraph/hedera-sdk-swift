// SPDX-License-Identifier: Apache-2.0

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class ExchangeRatesTests: XCTestCase {
    internal func testFromProtobuf() throws {
        let exchangeRates = try ExchangeRates.fromBytes(
            Data(hexEncoded: "0a1008b0ea0110b6b4231a0608f0bade9006121008b0ea01108cef231a060880d7de9006")!
        )

        assertSnapshot(matching: exchangeRates, as: .description)
    }
}
