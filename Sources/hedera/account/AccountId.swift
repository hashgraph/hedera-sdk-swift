public struct AccountId {
    let shard: UInt64
    let realm: UInt64
    let num: UInt64
    
    public init(accountNum: UInt64) {
        self = AccountId(shard: 0, realm: 0, num: accountNum)
    }
    
    public init(shard: UInt64, realm: UInt64, num: UInt64) {
        self.shard = shard
        self.realm = realm
        self.num = num
    }
}

extension AccountId: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(shard).\(realm).\(num)"
    }
    
    public var debugDescription: String {
        return description
    }
}

extension AccountId: LosslessStringConvertible {
    public init?(_ description: String) {
        let parts = description.split(separator: ".")
        if parts.count != 3 {
            return nil
        }
        
        guard let shard = UInt64(parts[parts.startIndex], radix: 10) else { return nil }
        guard let realm = UInt64(parts[parts.startIndex.advanced(by: 1)], radix: 10) else { return nil }
        guard let num = UInt64(parts[parts.startIndex.advanced(by: 2)], radix: 10) else { return nil }
        
        self.shard = shard
        self.realm = realm
        self.num = num
    }
}
