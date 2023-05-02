import HederaProtobufs

public struct TokenAllowance: ValidateChecksums {
    /// The token that the allowance pertains to.
    public let tokenId: TokenId

    /// The account ID of the token owner (ie. the grantor of the allowance).
    public let ownerAccountId: AccountId

    /// The account ID of the spender of the token allowance.
    public let spenderAccountId: AccountId

    /// The amount of the spender's token allowance.
    public let amount: UInt64

    internal func validateChecksums(on ledgerId: LedgerId) throws {
        try tokenId.validateChecksums(on: ledgerId)
        try ownerAccountId.validateChecksums(on: ledgerId)
        try spenderAccountId.validateChecksums(on: ledgerId)
    }
}

extension TokenAllowance: TryProtobufCodable {
    internal typealias Protobuf = Proto_TokenAllowance

    internal init(protobuf proto: Protobuf) throws {
        self.init(
            tokenId: .fromProtobuf(proto.tokenID),
            ownerAccountId: try .fromProtobuf(proto.owner),
            spenderAccountId: try .fromProtobuf(proto.spender),
            amount: UInt64(proto.amount)
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.tokenID = tokenId.toProtobuf()
            proto.owner = ownerAccountId.toProtobuf()
            proto.spender = spenderAccountId.toProtobuf()
            proto.amount = Int64(amount)
        }
    }
}
