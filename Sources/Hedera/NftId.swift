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

import CHedera

/// The unique identifier for a non-fungible token (NFT) instance on Hedera.
public final class NftId: Codable, LosslessStringConvertible, ExpressibleByStringLiteral, Equatable {
    /// The (non-fungible) token of which this NFT is an instance.
    public let tokenId: TokenId

    /// The unique identifier for this instance.
    public let serialNumber: UInt64

    /// Create a new `NftId` from the passed `tokenId` and `serialNumber`.
    public init(tokenId: TokenId, serialNumber: UInt64) {
        self.tokenId = tokenId
        self.serialNumber = serialNumber
    }

    public required convenience init?(_ description: String) {
        var shard: UInt64 = 0
        var realm: UInt64 = 0
        var num: UInt64 = 0
        var serialNumber: UInt64 = 0

        let err = hedera_nft_id_from_string(description, &shard, &realm, &num, &serialNumber)

        if err != HEDERA_ERROR_OK {
            return nil
        }

        self.init(tokenId: TokenId(shard: shard, realm: realm, num: num), serialNumber: serialNumber)
    }

    public required convenience init(stringLiteral value: StringLiteralType) {
        self.init(value)!
    }

    public required convenience init(from decoder: Decoder) throws {
        self.init(try decoder.singleValueContainer().decode(String.self))!
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        try container.encode(String(describing: self))
    }

    public static func == (lhs: NftId, rhs: NftId) -> Bool {
        lhs.serialNumber == rhs.serialNumber && lhs.tokenId == rhs.tokenId
    }

    public var description: String {
        "\(tokenId)/\(serialNumber)"
    }
}
