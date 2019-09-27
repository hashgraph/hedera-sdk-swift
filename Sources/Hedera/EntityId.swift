import SwiftProtobuf

public struct EntityId<Kind: EntityKind> {
    let shard: UInt64
    let realm: UInt64
    let num: UInt64

    public init(shard: UInt64 = 0, realm: UInt64 = 0, num: UInt64) {
        self.shard = shard
        self.realm = realm
        self.num = num
    }

    /// Create an EntityId with shard and realm set to 0.
    public init(_ num: UInt64) {
        self = EntityId(num: num)
    }
}

extension EntityId: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "\(shard).\(realm).\(num)"
    }
    
    public var debugDescription: String {
        description
    }
}

extension EntityId: LosslessStringConvertible {
    /// Create an EntityId from a String. It's valid to have just the number, e.g. "1000",
    /// in which case the shard and realm will default to 0.
    public init?(_ description: String) {
        let parts = description.split(separator: ".")

        // Giving just the account/contract/file number is fine, we default the rest of the parameters to 0
        if parts.count == 1 {
            guard let num = UInt64(parts[parts.startIndex], radix: 10) else { return nil }
            self =  EntityId(num)
        } else if parts.count == 3 {
            // In that case we probably have a full account/contract/file id  
            guard let shard = UInt64(parts[parts.startIndex], radix: 10) else { return nil }
            guard let realm = UInt64(parts[parts.startIndex.advanced(by: 1)], radix: 10) else { return nil }
            guard let num = UInt64(parts[parts.startIndex.advanced(by: 2)], radix: 10) else { return nil }
            
            self =  EntityId(shard: shard, realm: realm, num: num)
        } else {
            return nil
        }
    }
}

extension EntityId: Equatable {
    public static func == (lhs: EntityId, rhs: EntityId) -> Bool {
        lhs.shard == rhs.shard && lhs.realm == rhs.realm && lhs.num == rhs.num
    }
}

extension EntityId: Hashable {}

// "comforming" to ProtoConvertible
extension EntityId {
    func toProto() -> Proto_AccountID {
        var proto = Proto_AccountID()
        proto.shardNum = Int64(shard)
        proto.realmNum = Int64(realm)
        proto.accountNum = Int64(num)

        return proto
    }

    init(_ proto: Proto_AccountID) {
        shard = UInt64(proto.shardNum)
        realm = UInt64(proto.realmNum)
        num = UInt64(proto.accountNum)
    }

    func toProto() -> Proto_ContractID {
        var proto = Proto_ContractID()
        proto.shardNum = Int64(shard)
        proto.realmNum = Int64(realm)
        proto.contractNum = Int64(num)

        return proto
    }

    init(_ proto: Proto_ContractID) {
        shard = UInt64(proto.shardNum)
        realm = UInt64(proto.realmNum)
        num = UInt64(proto.contractNum)
    }

    func toProto() -> Proto_FileID {
        var proto = Proto_FileID()
        proto.shardNum = Int64(shard)
        proto.realmNum = Int64(realm)
        proto.fileNum = Int64(num)

        return proto
    }

    init(_ proto: Proto_FileID) {
        shard = UInt64(proto.shardNum)
        realm = UInt64(proto.realmNum)
        num = UInt64(proto.fileNum)
    }
}

/// This is an implementation detail. Please do not use directly in your own code
public protocol EntityKind {}

public struct AccountEntityKind: EntityKind {
    private init() {}   
}
public struct ContractEntityKind: EntityKind {
    private init() {}
}
public struct FileEntityKind: EntityKind {
    private init() {}
}

public typealias AccountId = EntityId<AccountEntityKind>
public typealias ContractId = EntityId<ContractEntityKind>
public typealias FileId = EntityId<FileEntityKind>