// SPDX-License-Identifier: Apache-2.0

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

extension Transaction {
    internal func makeProtoBody() throws -> Proto_TransactionBody {
        try Proto_TransactionBody(serializedBytes: makeSources().signedTransactions[0].bodyBytes)
    }
}
