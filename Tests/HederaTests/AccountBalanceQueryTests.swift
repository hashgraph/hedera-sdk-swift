import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class AccountBalanceQueryTests: XCTestCase {
    internal func testSerializeWithAccountId() {
        let proto = AccountBalanceQuery(accountId: 5005).toQueryProtobufWith(Proto_QueryHeader())
        assertSnapshot(matching: proto, as: .description)
    }

    internal func testSerializeWithContractId() {
        let proto = AccountBalanceQuery(contractId: 5005).toQueryProtobufWith(Proto_QueryHeader())
        assertSnapshot(matching: proto, as: .description)
    }
}
