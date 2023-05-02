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

/// An address as implemented in the Ethereum Virtual Machine.
public struct EvmAddress:
    CustomStringConvertible, LosslessStringConvertible, ExpressibleByStringLiteral, Hashable
{
    internal let data: Data

    internal init(_ data: Data) throws {
        guard data.count == 20 else {
            throw HError.basicParse("expected evm address to have 20 bytes, it had \(data.count)")
        }

        self.data = data
    }

    internal init<S: StringProtocol>(parsing description: S) throws {
        guard let description = description.stripPrefix("0x") else {
            throw HError.basicParse("expected evm address to have `0x` prefix")
        }

        guard let bytes = Data(hexEncoded: description) else {
            // todo: better error message
            throw HError.basicParse("invalid evm address")
        }

        try self.init(bytes)
    }

    /// Creates an EVM address from a string representation.
    ///
    /// - Parameters:
    ///    - description: A textual representation of an evm address.
    ///
    /// This will succeed if and only if:
    /// 1. `description` has a `0x` prefix.
    /// 2. `description` is a valid hex string.
    /// 3. the bytes decoded from `description` are exactly 20 bytes long.
    public init?(_ description: String) {
        try? self.init(parsing: description)
    }

    public init(stringLiteral value: StringLiteralType) {
        // swiftlint:disable:next force_try
        try! self.init(parsing: value)
    }

    /// Parse an evm address from a string.
    public static func fromString(_ description: String) throws -> Self {
        try Self(parsing: description)
    }

    /// Parse an evm address from bytes.
    public static func fromBytes(_ data: Data) throws -> Self {
        try Self(data)
    }

    public var description: String {
        "0x\(data.hexStringEncoded())"
    }

    /// Returns a textual representation of this evm address.
    public func toString() -> String {
        String(describing: self)
    }

    /// Returns a byte representation of this evm address.
    public func toBytes() -> Data {
        data
    }
}

#if compiler(<5.7)
    // for some reason this wasn't `Sendable` before `5.7`
    extension EvmAddress: @unchecked Sendable {}
#else
    extension EvmAddress: Sendable {}
#endif
