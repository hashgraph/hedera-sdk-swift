/*
 * ‌
 * Hedera Swift SDK
 *
 * Copyright (C) 2022 - 2024 Hedera Hashgraph, LLC
 *
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
 *
 */

import GRPC
import HederaProtobufs

/// Token's information related to the given Account.
///
/// See <a href="https://docs.hedera.com/guides/docs/hedera-api/basic-types/tokenrelationship">Hedera
/// Documentation</a>
public struct TokenRelationship: Sendable {
    /// The ID of the token
    public let tokenId: TokenId

    /// The Symbol of the token
    public let symbol: String

    /// For token of type FUNGIBLE_COMMON - the balance that the Account holds in the smallest
    /// denomination.
    ///
    /// For token of type NON_FUNGIBLE_UNIQUE - the number of NFTs held by the account
    public let balance: UInt64

    /// The KYC status of the account (KycNotApplicable, Granted or Revoked).
    ///
    /// If the token does not have KYC key, KycNotApplicable is returned
    public let kycStatus: Bool?

    /// The Freeze status of the account (FreezeNotApplicable, Frozen or Unfrozen).
    ///
    /// If the token does not have Freeze key, FreezeNotApplicable is returned
    public let freezeStatus: Bool?

    /// Specifies if the relationship is created implicitly.
    ///
    /// False : explicitly associated,
    /// True : implicitly associated.
    public let automaticAssociation: Bool

    public init(
        tokenId: TokenId, symbol: String, balance: UInt64, kycStatus: Bool?, freezeStatus: Bool?,
        automaticAssociation: Bool
    ) {
        self.tokenId = tokenId
        self.symbol = symbol
        self.balance = balance
        self.kycStatus = kycStatus
        self.freezeStatus = freezeStatus
        self.automaticAssociation = automaticAssociation
    }

}

extension TokenRelationship: TryProtobufCodable {
    internal typealias Protobuf = Proto_TokenRelationship

    internal init(protobuf proto: Protobuf) throws {
        var freezeStatus: Bool?
        var kycStatus: Bool?

        switch proto.freezeStatus {
        case .freezeNotApplicable:
            freezeStatus = nil
        case .frozen:
            freezeStatus = true
        case .unfrozen:
            freezeStatus = false
        case .unrecognized(_):
            fatalError("Unrecognized Freeze Status from Protobuf: \(proto.freezeStatus)")
        }

        switch proto.kycStatus {
        case .kycNotApplicable:
            kycStatus = nil
        case .granted:
            kycStatus = true
        case .revoked:
            kycStatus = false
        case .unrecognized(_):
            fatalError("Unrecognized KYC Status from protobuf: \(proto.kycStatus)")
        }

        self.init(
            tokenId: .fromProtobuf(proto.tokenID), symbol: proto.symbol, balance: proto.balance, kycStatus: kycStatus,
            freezeStatus: freezeStatus, automaticAssociation: proto.automaticAssociation)

    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            var protoFreezeStatus: Proto_TokenFreezeStatus
            var protoKycStatus: Proto_TokenKycStatus

            switch freezeStatus {
            case true:
                protoFreezeStatus = Proto_TokenFreezeStatus.frozen
            case false:
                protoFreezeStatus = Proto_TokenFreezeStatus.unfrozen
            case nil:
                protoFreezeStatus = Proto_TokenFreezeStatus.freezeNotApplicable
            case .some(_):
                fatalError("Unrecognized Freeze Status")
            }

            switch kycStatus {
            case true:
                protoKycStatus = Proto_TokenKycStatus.granted
            case false:
                protoKycStatus = Proto_TokenKycStatus.revoked
            case nil:
                protoKycStatus = Proto_TokenKycStatus.kycNotApplicable
            case .some(_):
                fatalError("Unrecognized KYC Status")
            }

            proto.tokenID = tokenId.toProtobuf()
            proto.balance = balance
            proto.symbol = symbol
            proto.freezeStatus = protoFreezeStatus
            proto.kycStatus = protoKycStatus
            proto.automaticAssociation = automaticAssociation
        }
    }
}
