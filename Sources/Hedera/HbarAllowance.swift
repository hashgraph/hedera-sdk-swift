import HederaProtobufs

public struct HbarAllowance: ValidateChecksums {
    /// The account that owns the Hbar associated with this allowance.
    public let ownerAccountId: AccountId

    /// The account that can spend the Hbar associated with this allowance.
    public let spenderAccountId: AccountId

    /// The amount of Hbar this allowance is worth.
    public let amount: Hbar

    internal func validateChecksums(on ledgerId: LedgerId) throws {
        try ownerAccountId.validateChecksums(on: ledgerId)
        try spenderAccountId.validateChecksums(on: ledgerId)
    }
}

extension HbarAllowance: TryProtobufCodable {
    internal typealias Protobuf = Proto_CryptoAllowance

    internal init(protobuf proto: Protobuf) throws {
        self.init(
            ownerAccountId: try .fromProtobuf(proto.owner),
            spenderAccountId: try .fromProtobuf(proto.spender),
            amount: .fromTinybars(proto.amount)
        )
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in
            proto.owner = ownerAccountId.toProtobuf()
            proto.spender = spenderAccountId.toProtobuf()
            proto.amount = amount.toTinybars()
        }
    }
}
