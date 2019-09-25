public struct FileId {
    let shard: UInt64
    let realm: UInt64
    let file: UInt64
    
    public init(shard: UInt64 = 0, realm: UInt64 = 0, file: UInt64) {
        self.shard = shard
        self.realm = realm
        self.file = file
    }

    /// Create a FileId with shard and realm set to 0.
    public init(_ file: UInt64) {
        self = FileId(file: file)
    }
}

extension FileId: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return "\(shard).\(realm).\(file)"
    }
    
    public var debugDescription: String {
        return description
    }
}

extension FileId: LosslessStringConvertible {
    /// Create a FileId from a String. It's valid to have just the file number, e.g. "1000",
    /// in which case the shard and realm will default to 0.
    public init?(_ description: String) {
        let parts = description.split(separator: ".")

        // Giving just the file number is fine, we default the rest of the parameters to 0
        if parts.count == 1 {
            guard let file = UInt64(parts[parts.startIndex], radix: 10) else { return nil }
            self = FileId(file: file)
        } else if parts.count == 3 {
            // In that case we probably have a full file id  
            guard let shard = UInt64(parts[parts.startIndex], radix: 10) else { return nil }
            guard let realm = UInt64(parts[parts.startIndex.advanced(by: 1)], radix: 10) else { return nil }
            guard let file = UInt64(parts[parts.startIndex.advanced(by: 2)], radix: 10) else { return nil }
            
            self = FileId(shard: shard, realm: realm, file: file)
        } else {
            return nil
        }
    }
}

extension FileId: Equatable {
    public static func == (lhs: FileId, rhs: FileId) -> Bool {
        return lhs.shard == rhs.shard && lhs.realm == rhs.realm && lhs.file == rhs.file
    }
}