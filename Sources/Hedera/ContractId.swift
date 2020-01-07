public final class ContractId: PublicKey {
    let id: EntityId

    // Overriding CustomStringConvertible and CustomDebugStringConvertible
    override public var description: String {
        id.description
    }
    override public var debugDescription: String {
        id.debugDescription
    }

    required convenience init?(_ proto: Proto_Key) {
        guard case let .contractID(contractId) =  proto.key else { return nil }

        self.init(contractId)
    }

    init(_ proto: Proto_ContractID) {
        id = EntityId(proto)
        super.init()
    }

    init(_  id: EntityId) {
        self.id = id
        super.init()
    }

    override func toProto() -> Proto_Key {
        var proto = Proto_Key()
        proto.contractID = toProto()

        return proto
    }

    func toProto() -> Proto_ContractID {
        var proto = Proto_ContractID()
        proto.shardNum = Int64(id.shard)
        proto.realmNum = Int64(id.realm)
        proto.contractNum = Int64(id.num)

        return proto
    }
}

extension ContractId: Equatable {
    public static func == (lhs: ContractId, rhs: ContractId) -> Bool {
        lhs.id == rhs.id
    }
}

extension ContractId: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension ContractId: LosslessStringConvertible {
    public convenience init?(_ description: String) {
        guard let id = EntityId(description) else { return nil }
        self.init(id)
    }
}

extension ContractId {
    public convenience init(shard: UInt64 = 0, realm: UInt64 = 0, num: UInt64) {
        self.init(EntityId(shard: shard, realm: realm, num: num))
    }

    /// Create a ContractId with shard and realm set to 0.
    public convenience init(_ num: UInt64) {
        self.init(EntityId(num: num))
    }

    public var shard: UInt64 {
        id.shard
    }

    public var realm: UInt64 {
        id.realm
    }

    public var contract: UInt64 {
        id.num
    }
}
