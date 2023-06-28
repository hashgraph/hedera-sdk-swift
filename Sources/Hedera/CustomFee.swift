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
import NumberKit

// swiftlint:disable file_length

/// A transfer fee to assess during a `TransferTransaction` that transfers units of
/// the token to which the fee is attached.
public protocol CustomFee {
    /// The account to receive the custom fee.
    var feeCollectorAccountId: AccountId? { get set }

    /// True if all collectors are exempt from fees, false otherwise.
    var allCollectorsAreExempt: Bool { get set }

    /// Sets the account to recieve the custom fee.
    @discardableResult
    mutating func feeCollectorAccountId(_ feeCollectorAccountId: AccountId) -> Self

    /// Set to `true` if all collectors should be exempt from fees, or to false otherwise.
    @discardableResult
    mutating func allCollectorsAreExempt(_ allCollectorsAreExempt: Bool) -> Self
}

extension CustomFee {
    /// Sets the account to recieve the custom fee.
    @discardableResult
    public mutating func feeCollectorAccountId(_ feeCollectorAccountId: AccountId) -> Self {
        self.feeCollectorAccountId = feeCollectorAccountId

        return self
    }

    /// Set to `true` if all collectors should be exempt from fees, or to false otherwise.
    @discardableResult
    public mutating func allCollectorsAreExempt(_ allCollectorsAreExempt: Bool) -> Self {
        self.allCollectorsAreExempt = true

        return self
    }
}

/// A transfer fee to assess during a `TransferTransaction` that transfers units of
/// the token to which the fee is attached.
public enum AnyCustomFee: Equatable {
    /// A fee that costs a fixed number of hbar/tokens.
    case fixed(FixedFee)
    /// A fee that costs a fraction of the transferred amount.
    case fractional(FractionalFee)
    /// A fee that charges a royalty for NFT transfers.
    case royalty(RoyaltyFee)

    /// Decode `Self` from protobuf-encoded `bytes`.
    ///
    /// - Throws: ``HError/ErrorKind/fromProtobuf`` if:
    ///           decoding the bytes fails to produce a valid protobuf, or
    ///            decoding the protobuf fails.
    public static func fromBytes(_ bytes: Data) throws -> Self {
        try Self(protobufBytes: bytes)
    }

    /// Convert `self` to protobuf encoded data.
    public func toBytes() -> Data {
        toProtobufBytes()
    }
}

extension AnyCustomFee: CustomFee {
    public var feeCollectorAccountId: AccountId? {
        get {
            switch self {
            case .fixed(let fee):
                return fee.feeCollectorAccountId
            case .fractional(let fee):
                return fee.feeCollectorAccountId
            case .royalty(let fee):
                return fee.feeCollectorAccountId
            }

        }
        set(newValue) {
            switch self {
            case .fixed(var fee):
                fee.feeCollectorAccountId = newValue
            case .fractional(var fee):
                fee.feeCollectorAccountId = newValue
            case .royalty(var fee):
                fee.feeCollectorAccountId = newValue
            }
        }
    }

    public var allCollectorsAreExempt: Bool {
        get {
            switch self {
            case .fixed(let fee):
                return fee.allCollectorsAreExempt
            case .fractional(let fee):
                return fee.allCollectorsAreExempt
            case .royalty(let fee):
                return fee.allCollectorsAreExempt
            }

        }
        set(newValue) {
            switch self {
            case .fixed(var fee):
                fee.allCollectorsAreExempt = newValue
            case .fractional(var fee):
                fee.allCollectorsAreExempt = newValue
            case .royalty(var fee):
                fee.allCollectorsAreExempt = newValue
            }
        }
    }
}

extension AnyCustomFee: ValidateChecksums {
    internal func validateChecksums(on ledgerId: LedgerId) throws {
        switch self {
        case .fixed(let fee):
            try fee.validateChecksums(on: ledgerId)
        case .fractional(let fee):
            try fee.validateChecksums(on: ledgerId)
        case .royalty(let fee):
            try fee.validateChecksums(on: ledgerId)
        }
    }
}

extension AnyCustomFee: TryProtobufCodable {
    internal typealias Protobuf = Proto_CustomFee

    internal init(protobuf proto: Protobuf) throws {
        let feeCollectorAccountIdProto = proto.hasFeeCollectorAccountID ? proto.feeCollectorAccountID : nil
        let feeCollectorAccountId: AccountId? = try .fromProtobuf(feeCollectorAccountIdProto)
        let allCollectorsAreExempt = proto.allCollectorsAreExempt

        guard let fee = proto.fee else {
            throw HError.fromProtobuf("`CustomFee` kind was unexpectedly nil")
        }

        switch fee {
        case .fixedFee(let fixed):
            self = .fixed(
                FixedFee(
                    fromFee: fixed,
                    feeCollectorAccountId: feeCollectorAccountId,
                    allCollectorsAreExempt: allCollectorsAreExempt
                )
            )
        case .fractionalFee(let fractional):
            self = .fractional(
                FractionalFee(
                    fromFee: fractional,
                    feeCollectorAccountId: feeCollectorAccountId,
                    allCollectorsAreExempt: allCollectorsAreExempt
                )
            )
        case .royaltyFee(let royalty):
            self = .royalty(
                RoyaltyFee(
                    fromFee: royalty,
                    feeCollectorAccountId: feeCollectorAccountId,
                    allCollectorsAreExempt: allCollectorsAreExempt
                )
            )
        }

    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            switch self {
            case .fixed(let fee):
                proto.fee = .fixedFee(fee.toFeeProtobuf())
            case .fractional(let fee):
                proto.fee = .fractionalFee(fee.toFeeProtobuf())
            case .royalty(let fee):
                proto.fee = .royaltyFee(fee.toFeeProtobuf())
            }

            if let feeCollectorAccountId = feeCollectorAccountId {
                proto.feeCollectorAccountID = feeCollectorAccountId.toProtobuf()
            }

            proto.allCollectorsAreExempt = allCollectorsAreExempt
        }
    }
}

/// A fixed number of units (hbar or token) to assess as a fee during a `TransferTransaction` that transfers
/// units of the token to which this fixed fee is attached.
public struct FixedFee: CustomFee, Equatable, ValidateChecksums {
    public var feeCollectorAccountId: AccountId?

    public var allCollectorsAreExempt: Bool

    /// Create a new `CustomFixedFee`.
    public init(
        amount: UInt64 = 0,
        denominatingTokenId: TokenId? = nil,
        feeCollectorAccountId: AccountId? = nil,
        allCollectorsAreExempt: Bool = false
    ) {
        self.amount = amount
        self.denominatingTokenId = denominatingTokenId
        self.feeCollectorAccountId = feeCollectorAccountId
        self.allCollectorsAreExempt = allCollectorsAreExempt
    }

    fileprivate init(
        fromFee proto: Proto_FixedFee,
        feeCollectorAccountId: AccountId?,
        allCollectorsAreExempt: Bool
    ) {
        let denominatingTokenId = proto.hasDenominatingTokenID ? proto.denominatingTokenID : nil

        self.init(
            amount: UInt64(proto.amount),
            denominatingTokenId: .fromProtobuf(denominatingTokenId),
            feeCollectorAccountId: feeCollectorAccountId,
            allCollectorsAreExempt: allCollectorsAreExempt
        )
    }

    /// The number of units to assess as a fee.
    ///
    /// If the `denominatingTokenId` is unset, this value is in HBAR and must be set in **tinybars**.
    public var amount: UInt64

    /// Sets the number of units to assess as a fee.
    @discardableResult
    public mutating func amount(_ amount: UInt64) -> Self {
        self.amount = amount

        return self
    }

    /// The denomination of the fee.
    ///
    /// Taken as HBAR if left unset.
    /// When used in a `TokenCreateTransaction`, taken as the newly created token ID if set to `0.0.0`.
    public var denominatingTokenId: TokenId?

    /// Sets the denomination of the fee.
    @discardableResult
    public mutating func denominatingTokenId(_ denominatingTokenId: TokenId) -> Self {
        self.denominatingTokenId = denominatingTokenId

        return self
    }

    internal func validateChecksums(on ledgerId: LedgerId) throws {
        try denominatingTokenId?.validateChecksums(on: ledgerId)
        try feeCollectorAccountId?.validateChecksums(on: ledgerId)
    }

    fileprivate func toFeeProtobuf() -> Proto_FixedFee {
        .with { proto in
            proto.amount = Int64(amount)
            if let denominatingTokenId = denominatingTokenId {
                proto.denominatingTokenID = denominatingTokenId.toProtobuf()
            }
        }
    }
}

/// A fraction of the transferred units of a token to assess as a fee.
///
/// The amount assessed will never be less than the given `minimumAmount`, and never greater
/// than the given `maximumAmount`.
///
/// The denomination is always in units of the token to which this fractional fee is attached.
public struct FractionalFee: CustomFee, Equatable, ValidateChecksums {
    public var feeCollectorAccountId: AccountId?

    public var allCollectorsAreExempt: Bool

    /// Create a new `CustomFixedFee`.
    public init(
        amount: Rational<UInt64> = "1/1",
        minimumAmount: UInt64 = 0,
        maximumAmount: UInt64 = 0,
        assessmentMethod: FeeAssessmentMethod = .exclusive,
        feeCollectorAccountId: AccountId? = nil,
        allCollectorsAreExempt: Bool = false
    ) {
        self.denominator = amount.denominator
        self.numerator = amount.numerator
        self.minimumAmount = minimumAmount
        self.maximumAmount = maximumAmount
        self.assessmentMethod = assessmentMethod
        self.feeCollectorAccountId = feeCollectorAccountId
        self.allCollectorsAreExempt = allCollectorsAreExempt
    }

    fileprivate init(
        fromFee proto: Proto_FractionalFee,
        feeCollectorAccountId: AccountId?,
        allCollectorsAreExempt: Bool
    ) {
        denominator = UInt64(proto.fractionalAmount.denominator)
        numerator = UInt64(proto.fractionalAmount.numerator)
        minimumAmount = UInt64(proto.minimumAmount)
        maximumAmount = UInt64(proto.maximumAmount)
        assessmentMethod = .init(netOfTransfers: proto.netOfTransfers)
        self.feeCollectorAccountId = feeCollectorAccountId
        self.allCollectorsAreExempt = allCollectorsAreExempt
    }

    /// The fraction of the transferred units to assess as a fee.
    public var amount: Rational<UInt64> {
        get {
            Rational(numerator, denominator)
        }
        set(new) {
            numerator = new.numerator
            denominator = new.denominator
        }
    }

    /// Denominator of `amount`
    public var denominator: UInt64

    /// Numerator of `amount`
    public var numerator: UInt64

    /// Sets the fraction of the transferred units to assess as a fee.
    @discardableResult
    public mutating func amount(_ amount: Rational<UInt64>) -> Self {
        self.amount = amount

        return self
    }

    /// Sets the denominator of `amount`
    ///
    /// - Parameters:
    ///   - denominator: the new denominator to use.
    ///
    /// - Returns: `self`.
    @discardableResult
    public mutating func denominator(_ denominator: UInt64) -> Self {
        self.denominator = denominator

        return self
    }

    /// Sets the numerator of `amount`
    ///
    /// - Parameters:
    ///   - numerator: the new numerator to use.
    ///
    /// - Returns: `self`.
    @discardableResult
    public mutating func numerator(_ numerator: UInt64) -> Self {
        self.numerator = numerator

        return self
    }

    /// The minimum amount to assess.
    public var minimumAmount: UInt64

    /// Sets the minimum amount to assess.
    @discardableResult
    public mutating func minimumAmount(_ minimumAmount: UInt64) -> Self {
        self.minimumAmount = minimumAmount

        return self
    }

    /// The maximum amount to assess.
    public var maximumAmount: UInt64

    /// Sets the maximum amount to assess.
    @discardableResult
    public mutating func maximumAmount(_ maximumAmount: UInt64) -> Self {
        self.maximumAmount = maximumAmount

        return self
    }

    /// Whether the fee assessment should be in addition to the transfer amount or not.
    ///
    /// If `exclusive`, assesses the fee to the sender, so the receiver gets the full amount from the token
    /// transfer list, and the sender is charged an additional fee.
    ///
    /// If `inclusive`, the receiver does NOT get the full amount, but only what is left over after
    /// paying the fractional fee.
    public var assessmentMethod: FeeAssessmentMethod

    /// Sets whether the fee assessment should be in addition to the transfer amount or not.
    @discardableResult
    public mutating func assessmentMethod(_ assessmentMethod: FeeAssessmentMethod) -> Self {
        self.assessmentMethod = assessmentMethod

        return self
    }

    internal func validateChecksums(on ledgerId: LedgerId) throws {
        try feeCollectorAccountId?.validateChecksums(on: ledgerId)
    }

    internal func toFeeProtobuf() -> Proto_FractionalFee {
        .with { proto in
            proto.fractionalAmount = amount.toProtobuf()
            proto.minimumAmount = Int64(minimumAmount)
            proto.maximumAmount = Int64(maximumAmount)
            proto.netOfTransfers = assessmentMethod == .exclusive
        }
    }
}

extension FractionalFee {
    /// Enum for the fee assessment method.
    ///
    /// The terminology here (exclusive vs inclusive) is borrowed from tax assessment.
    public enum FeeAssessmentMethod: Equatable, Hashable {
        /// - Returns: `inclusive` if `false`, `exclusive` if `true`.
        public init(netOfTransfers: Bool) {
            self = netOfTransfers ? .exclusive : .inclusive
        }

        /// The recipient recieves the transfer amount, minus the fee.
        ///
        /// If Alice is paying Bob, and an `inclusive` fractional fee is collected to be sent to Charlie,
        /// the amount Alice declares she will pay in the transfer transaction *includes* the fee amount.
        case inclusive

        /// The recipient recieves the whole transfer amount, and an extra fee is charged to the sender.
        ///
        /// If Alice is paying Bob, and an `exclusive` fractional fee is collected to be sent to Charlie,
        /// the amount Alice declares she will pay in the transfer transaction *does not include* the fee amount.
        case exclusive
    }
}

/// A fee to assess during a `TransferTransaction` that changes ownership of an NFT.
///
/// Defines the fraction of the fungible value exchanged for an NFT that the ledger
/// should collect as a royalty.
public struct RoyaltyFee: CustomFee, Equatable {
    public var feeCollectorAccountId: AccountId?

    public var allCollectorsAreExempt: Bool

    /// Create a new `CustomRoyaltyFee`.
    public init(
        exchangeValue: Rational<UInt64> = "1/1",
        fallbackFee: FixedFee? = nil,
        feeCollectorAccountId: AccountId? = nil,
        allCollectorsAreExempt: Bool = false
    ) {
        self.init(
            numerator: exchangeValue.numerator,
            denominator: exchangeValue.denominator,
            fallbackFee: fallbackFee,
            feeCollectorAccountId: feeCollectorAccountId,
            allCollectorsAreExempt: allCollectorsAreExempt
        )
    }

    /// Create a new `CustomRoyaltyFee`
    public init(
        numerator: UInt64 = 1,
        denominator: UInt64 = 1,
        fallbackFee: FixedFee? = nil,
        feeCollectorAccountId: AccountId? = nil,
        allCollectorsAreExempt: Bool = false
    ) {
        self.numerator = numerator
        self.denominator = denominator
        self.fallbackFee = fallbackFee
        self.feeCollectorAccountId = feeCollectorAccountId
        self.allCollectorsAreExempt = allCollectorsAreExempt
    }

    fileprivate init(
        fromFee proto: Proto_RoyaltyFee,
        feeCollectorAccountId: AccountId?,
        allCollectorsAreExempt: Bool
    ) {
        let fallbackFee = proto.hasFallbackFee ? proto.fallbackFee : nil
        self.init(
            numerator: UInt64(proto.exchangeValueFraction.numerator),
            denominator: UInt64(proto.exchangeValueFraction.denominator),
            fallbackFee: fallbackFee.map { protoFee in
                FixedFee(fromFee: protoFee, feeCollectorAccountId: nil, allCollectorsAreExempt: false)
            },
            feeCollectorAccountId: feeCollectorAccountId,
            allCollectorsAreExempt: allCollectorsAreExempt
        )
    }

    /// The fraction of fungible value exchanged for an NFT to collect as royalty.
    public var exchangeValue: Rational<UInt64> {
        get {
            Rational(numerator, denominator)
        }
        set(new) {
            numerator = new.numerator
            denominator = new.denominator
        }
    }

    /// Denominator of `exchangeValue`
    public var denominator: UInt64

    /// Numerator of `exchangeValue`
    public var numerator: UInt64

    /// Sets the fraction of fungible value exchanged for an NFT to collect as royalty.
    @discardableResult
    public mutating func exchangeValue(_ exchangeValue: Rational<UInt64>) -> Self {
        self.exchangeValue = exchangeValue

        return self
    }

    /// Sets the denominator of `exchangeValue`
    ///
    /// - Parameters:
    ///   - denominator: the new denominator to use.
    ///
    /// - Returns: `self`.
    @discardableResult
    public mutating func denominator(_ denominator: UInt64) -> Self {
        self.denominator = denominator

        return self
    }

    /// Sets the numerator of `exchangeValue`
    ///
    /// - Parameters:
    ///   - numerator: the new numerator to use.
    ///
    /// - Returns: `self`.
    @discardableResult
    public mutating func numerator(_ numerator: UInt64) -> Self {
        self.numerator = numerator

        return self
    }

    /// If present, the fixed fee to assess to the NFT receiver when no fungible value is exchanged
    /// with the sender.
    public var fallbackFee: FixedFee?

    /// Set the fixed fee to assess to the NFT receiver when no fungible value is exchanged
    /// with the sender.
    @discardableResult
    public mutating func fallbackFee(_ fallbackFee: FixedFee) -> Self {
        self.fallbackFee = fallbackFee

        return self
    }

    internal func validateChecksums(on ledgerId: LedgerId) throws {
        try fallbackFee?.validateChecksums(on: ledgerId)
        try feeCollectorAccountId?.validateChecksums(on: ledgerId)
    }

    internal func toFeeProtobuf() -> Proto_RoyaltyFee {
        .with { proto in
            proto.exchangeValueFraction = self.exchangeValue.toProtobuf()
            if let fallbackFee = self.fallbackFee {
                proto.fallbackFee = fallbackFee.toFeeProtobuf()
            }
        }
    }
}
