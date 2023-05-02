import HederaProtobufs
import SwiftProtobuf

public struct TokenNftAllowance: ValidateChecksums {
    /// The token ID that this allowance is for.
    public let tokenId: TokenId

    /// The account that owns the NFTs.
    public let ownerAccountId: AccountId

    /// The account that can spend the NFTs.
    public let spenderAccountId: AccountId

    /// The list of serials that the spender is permitted to transfer.
    public var serials: [UInt64]

    /// If true, the spender has access to all of the owner's current and future NFTs with the associated token ID.
    public let approvedForAll: Bool?

    /// The account ID of the spender who is granted approved for all allowance and granting
    /// approval on an NFT serial to another spender.
    public let delegatingSpenderAccountId: AccountId?

    internal func validateChecksums(on ledgerId: LedgerId) throws {
        try tokenId.validateChecksums(on: ledgerId)
        try ownerAccountId.validateChecksums(on: ledgerId)
        try spenderAccountId.validateChecksums(on: ledgerId)
        try delegatingSpenderAccountId?.validateChecksums(on: ledgerId)
    }
}

extension TokenNftAllowance: TryProtobufCodable {
    internal typealias Protobuf = Proto_NftAllowance

    internal init(protobuf proto: Protobuf) throws {
        self.init(
            tokenId: .fromProtobuf(proto.tokenID),
            ownerAccountId: try .fromProtobuf(proto.owner),
            spenderAccountId: try .fromProtobuf(proto.spender),
            serials: proto.serialNumbers.map(UInt64.init),
            approvedForAll: proto.hasApprovedForAll ? proto.approvedForAll.value : nil,
            delegatingSpenderAccountId: proto.hasDelegatingSpender ? try .fromProtobuf(proto.delegatingSpender) : nil
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.tokenID = tokenId.toProtobuf()
            proto.owner = ownerAccountId.toProtobuf()
            proto.spender = spenderAccountId.toProtobuf()
            proto.serialNumbers = serials.map(Int64.init)

            if let approvedForAll = approvedForAll {
                proto.approvedForAll = Google_Protobuf_BoolValue(approvedForAll)
            }

            delegatingSpenderAccountId?.toProtobufInto(&proto.delegatingSpender)
        }
    }
}

public struct NftRemoveAllowance: ValidateChecksums {
    /// token that the allowance pertains to
    public let tokenId: TokenId

    /// The account ID that owns token.
    public let ownerAccountId: AccountId

    /// The list of serial numbers to remove allowances from.
    public var serials: [UInt64]

    internal func validateChecksums(on ledgerId: LedgerId) throws {
        try tokenId.validateChecksums(on: ledgerId)
        try ownerAccountId.validateChecksums(on: ledgerId)
    }
}

extension NftRemoveAllowance: TryProtobufCodable {
    internal typealias Protobuf = Proto_NftRemoveAllowance

    internal init(protobuf proto: Protobuf) throws {
        self.init(
            tokenId: .fromProtobuf(proto.tokenID),
            ownerAccountId: try .fromProtobuf(proto.owner),
            serials: proto.serialNumbers.map(UInt64.init)
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.tokenID = tokenId.toProtobuf()
            proto.owner = ownerAccountId.toProtobuf()
            proto.serialNumbers = serials.map(Int64.init)
        }
    }
}
