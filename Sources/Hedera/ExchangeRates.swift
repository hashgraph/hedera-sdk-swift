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

/// The current and next exchange rates between ``Hbar`` and USD-cents.
public struct ExchangeRates: Sendable {
    /// The current exchange rate between Hbar and USD-cents.
    public let currentRate: ExchangeRate
    /// The next exchange rate between Hbar and USD-cents.
    public let nextRate: ExchangeRate

    /// Decode `Self` from protobuf-encoded `bytes`.
    ///
    /// - Throws: ``HError/ErrorKind/fromProtobuf`` if:
    ///           decoding the bytes fails to produce a valid protobuf, or
    ///            decoding the protobuf fails.
    public static func fromBytes(_ bytes: Data) throws -> Self {
        try Self(protobufBytes: bytes)
    }
}

extension ExchangeRates: ProtobufCodable {
    internal typealias Protobuf = Proto_ExchangeRateSet

    internal init(protobuf proto: Protobuf) {
        self.init(
            currentRate: .fromProtobuf(proto.currentRate),
            nextRate: .fromProtobuf(proto.nextRate)
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.currentRate = currentRate.toProtobuf()
            proto.nextRate = nextRate.toProtobuf()
        }
    }
}

/// Denotes a conversion between Hbars and cents (USD).
public struct ExchangeRate: Sendable {
    /// Denotes Hbar equivalent to cents (USD).
    public let hbars: UInt32

    /// Denotes cents (USD) equivalent to Hbar.
    public let cents: UInt32

    /// Expiration time of this exchange rate.
    public let expirationTime: Timestamp

    /// Calculated exchange rate.
    public var exchangeRateInCents: Double {
        Double(cents) / Double(hbars)
    }
}

extension ExchangeRate: ProtobufCodable {
    internal typealias Protobuf = Proto_ExchangeRate

    internal init(protobuf proto: Protobuf) {
        self.init(
            hbars: UInt32(proto.hbarEquiv),
            cents: UInt32(proto.centEquiv),
            expirationTime: .init(seconds: UInt64(proto.expirationTime.seconds), subSecondNanos: 0)
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.hbarEquiv = Int32(bitPattern: hbars)
            proto.centEquiv = Int32(bitPattern: cents)
            proto.expirationTime = Proto_TimestampSeconds.with { $0.seconds = Int64(expirationTime.seconds) }
        }
    }
}
