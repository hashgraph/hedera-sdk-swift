protocol Byteable {
    func asBytes() -> [UInt8]
}

extension UInt32: Byteable {
    func asBytes() -> [UInt8]  {
        withUnsafeBytes(of: self.bigEndian) { Array($0) }
    }
}

extension UInt64: Byteable {
    func asBytes() -> [UInt8]  {
        withUnsafeBytes(of: self.bigEndian) { Array($0) }
    }
}

extension Int32: Byteable {
    func asBytes() -> [UInt8]  {
        withUnsafeBytes(of: self.bigEndian) { Array($0) }
    }
}

extension Int64: Byteable {
    func asBytes() -> [UInt8]  {
        withUnsafeBytes(of: self.bigEndian) { Array($0) }
    }
}

extension String: Byteable {
    func asBytes() -> [UInt8]  {
        Array(self.utf8)
    }
}
