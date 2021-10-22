import HederaProtoServices

public final class FileId {
  let id: EntityId

  init(_ entity: EntityId) {
    id = entity
  }
}

extension FileId: ProtobufConvertible {
  public func toProtobuf() -> Proto_FileID {
    var proto = Proto_FileID()
    proto.shardNum = Int64(id.shard)
    proto.realmNum = Int64(id.realm)
    proto.fileNum = Int64(id.num)
    return proto
  }

  public convenience init(_ proto: Proto_FileID) {
    self.init(EntityId(proto))
  }
}

extension FileId: Equatable {
  public static func == (lhs: FileId, rhs: FileId) -> Bool {
    lhs.id == rhs.id
  }
}

extension FileId: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension FileId: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    id.description
  }

  public var debugDescription: String {
    id.debugDescription
  }
}

extension FileId: LosslessStringConvertible {
  public convenience init?(_ description: String) {
    guard let id = EntityId(description) else { return nil }
    self.init(id)
  }
}

extension FileId {
  public convenience init(shard: UInt64 = 0, realm: UInt64 = 0, num: UInt64) {
    self.init(EntityId(shard: shard, realm: realm, num: num))
  }

  /// Create an AccountId with shard and realm set to 0.
  public convenience init(_ num: UInt64) {
    self.init(EntityId(num: num))
  }

  public var shard: UInt64 {
    id.shard
  }

  public var realm: UInt64 {
    id.realm
  }

  public var file: UInt64 {
    id.num
  }
}
