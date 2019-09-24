import Sodium

struct HexDecodeError: Error {}

func hexDecode<S>(_ hex: S) throws -> Bytes where S: StringProtocol {
    if !hex.count.isMultiple(of: 2) {
        throw HexDecodeError()
    }

    let bytesLen = hex.count / 2
    var bytes = Bytes(repeating: 0, count: bytesLen)

    for index in 0 ..< bytesLen {
        let start = hex.index(hex.startIndex, offsetBy: index * 2)
        let end = hex.index(start, offsetBy: 2)
        
        guard let byte = UInt8(hex[start ..< end], radix: 16) else { throw HexDecodeError() }
        bytes[index] = byte
    }

    return bytes
}

func hexEncode(bytes: Bytes, prefixed with: String = "") -> String {
    var result = String(with)
    for byte in bytes {
        result.append(String(format: "%02x", byte))
    }

    return result
}
