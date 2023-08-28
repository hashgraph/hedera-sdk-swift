/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
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

import Foundation
import HederaProtobufs

/// A token <-> account association.
public struct TokenAssociation: Sendable {
    /// The token involved in the association.
    public let tokenId: TokenId

    /// The account involved in the association.
    public let accountId: AccountId

    /// Convert self to protobuf encoded bytes.
    public func toBytes() -> Data {
        toProtobufBytes()
    }
}

extension TokenAssociation: TryProtobufCodable {
    internal typealias Protobuf = Proto_TokenAssociation

    internal init(protobuf proto: Protobuf) throws {
        tokenId = .fromProtobuf(proto.tokenID)
        accountId = try .fromProtobuf(proto.accountID)
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.tokenID = tokenId.toProtobuf()
            proto.accountID = accountId.toProtobuf()
        }
    }
}
