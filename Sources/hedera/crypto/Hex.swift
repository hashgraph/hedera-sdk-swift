import Sodium

struct HexDecodeError: Error {}

func hexDecode<S>(_ hex: S) -> Result<Bytes, HexDecodeError> where S: StringProtocol {
    if hex.count % 2 != 0 {
        return .failure(HexDecodeError())
    }

    let bytesLen = hex.count / 2
    var bytes = Bytes(repeating: 0, count: bytesLen)

    for index in 0 ..< bytesLen {
        let start = hex.index(hex.startIndex, offsetBy: index * 2)
        let end = hex.index(start, offsetBy: 2)
        bytes[index] = UInt8(hex[start ..< end], radix: 16)!
    }

    return .success(bytes)
}

func hexEncode<S>(bytes: Bytes, prefixed with: S) -> String where S: StringProtocol {
    var result = String(with)
    for byte in bytes {
        result.append(String(format: "%02x", byte))
    }

    return result
}
