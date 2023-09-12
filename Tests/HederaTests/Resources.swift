/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2023 - 2023 Hedera Hashgraph, LLC
 * ​
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ‍
 */

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal enum Resources {
    internal static let nodeAccountIds: [AccountId] = [5005, 5006]
    internal static let validStart = Timestamp(seconds: 1_554_158_542, subSecondNanos: 0)
    internal static let txId = TransactionId(accountId: 5006, validStart: validStart)
    internal static let scheduleId = ScheduleId("0.0.555")
    internal static let accountId = AccountId("0.0.5009")
    internal static let fileId = FileId("1.2.3")
    internal static let tokenId = TokenId("0.3.5")
    internal static let topicId = TopicId("4.4.4")

    // some unused private key
    internal static let privateKey: PrivateKey =
        "302e020100300506032b657004220420db484b828e64b2d8f12ce3c0a0e93a0b8cce7af1bb8f39c97732394482538e10"

    internal static var publicKey: PublicKey {
        privateKey.publicKey
    }

}
