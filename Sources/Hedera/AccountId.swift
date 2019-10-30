public final class AccountId: ProtoConvertible {
    let id: EntityId
    
    func toProto() -> Proto_AccountID {
        var proto = Proto_AccountID()
        proto.shardNum = Int64(id.shard)
        proto.realmNum = Int64(id.realm)
        proto.accountNum = Int64(id.num)
        return proto
    }

    init(_ proto: Proto_AccountID) {
        id = EntityId(proto)
    }
    
    init(_ entity: EntityId) {
        id = entity
    }
}

extension AccountId: Equatable {
    public static func == (lhs: AccountId, rhs: AccountId) -> Bool {
        lhs.id == rhs.id
    }
}

extension AccountId: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension AccountId: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        id.description
    }
    
    public var debugDescription: String {
        id.debugDescription
    }
}

extension AccountId: LosslessStringConvertible {
    public convenience init?(_ description: String) {
        guard let id = EntityId(description) else { return nil }
        self.init(id)
    }
}

extension AccountId {
    public convenience init(shard: UInt64 = 0, realm: UInt64 = 0, num: UInt64) {
        self.init(EntityId(shard: shard, realm: realm, num: num))
    }

    /// Create an EntityId with shard and realm set to 0.
    public convenience init(_ num: UInt64) {
        self.init(EntityId(num: num))
    }
}
