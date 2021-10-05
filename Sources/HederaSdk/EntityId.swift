import HederaProtoServices

struct EntityId {
  let shard: UInt64
  let realm: UInt64
  let num: UInt64

  init(shard: UInt64 = 0, realm: UInt64 = 0, num: UInt64) {
    self.shard = shard
    self.realm = realm
    self.num = num
  }

  /// Create an EntityId with shard and realm set to 0.
  init(_ num: UInt64) {
    self = EntityId(num: num)
  }

  init(_ proto: Proto_AccountID) {
    shard = UInt64(proto.shardNum)
    realm = UInt64(proto.realmNum)
    num = UInt64(proto.accountNum)
  }

  init(_ proto: Proto_ContractID) {
    shard = UInt64(proto.shardNum)
    realm = UInt64(proto.realmNum)
    num = UInt64(proto.contractNum)
  }

  init(_ proto: Proto_FileID) {
    shard = UInt64(proto.shardNum)
    realm = UInt64(proto.realmNum)
    num = UInt64(proto.fileNum)
  }

  init(_ proto: Proto_TokenID) {
    shard = UInt64(proto.shardNum)
    realm = UInt64(proto.realmNum)
    num = UInt64(proto.tokenNum)
  }
}

extension EntityId: Equatable {
  public static func == (lhs: EntityId, rhs: EntityId) -> Bool {
    lhs.shard == rhs.shard && lhs.realm == rhs.realm && lhs.num == rhs.num
  }
}

extension EntityId: Hashable {}

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
      self = EntityId(num)
    } else if parts.count == 3 {
      // In that case we probably have a full account/contract/file id
      guard let shard = UInt64(parts[parts.startIndex], radix: 10) else { return nil }
      guard let realm = UInt64(parts[parts.startIndex.advanced(by: 1)], radix: 10) else {
        return nil
      }
      guard let num = UInt64(parts[parts.startIndex.advanced(by: 2)], radix: 10) else { return nil }

      self = EntityId(shard: shard, realm: realm, num: num)
    } else {
      return nil
    }
  }
}
