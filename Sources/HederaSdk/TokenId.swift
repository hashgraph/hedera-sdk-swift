import HederaProtoServices

public final class TokenId {
  var id: EntityId

  init(_ entity: EntityId) {
    id = entity
  }
}

extension TokenId: ProtobufConvertible {
  public func toProtobuf() -> Proto_TokenID {
    var proto = Proto_TokenID()
    proto.shardNum = Int64(id.shard)
    proto.realmNum = Int64(id.realm)
    proto.tokenNum = Int64(id.num)
    return proto
  }

  public convenience init(_ proto: Proto_TokenID) {
    self.init(EntityId(proto))
  }
}

extension TokenId: Equatable {
  public static func == (lhs: TokenId, rhs: TokenId) -> Bool {
    lhs.id == rhs.id
  }
}

extension TokenId: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

extension TokenId: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    id.description
  }

  public var debugDescription: String {
    id.debugDescription
  }
}

extension TokenId: LosslessStringConvertible {
  public convenience init?(_ description: String) {
    guard let id = EntityId(description) else { return nil }
    self.init(id)
  }
}

extension TokenId {
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

  public var token: UInt64 {
    id.num
  }

  public func validate(_ client: Client) throws {
    try id.validate(client)
  }
}
