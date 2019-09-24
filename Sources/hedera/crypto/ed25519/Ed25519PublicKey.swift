import Sodium
import Foundation

let ed25519PublicKeyPrefix = "302a300506032b6570032100"
let ed25519PublicKeyLength = 32

public struct Ed25519PublicKey {
    private let inner: Bytes

    public init?(bytes: Bytes) {
        if bytes.count == ed25519PublicKeyLength {
            inner = bytes
        } else {
            return nil
        }
    }

    var bytes: Bytes {
        return inner
    }
}

extension Ed25519PublicKey: CustomStringConvertible {
    public var description: String {
        return hexEncode(bytes: inner, prefixed: ed25519PublicKeyPrefix)
    }
}

extension Ed25519PublicKey: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

extension Ed25519PublicKey: LosslessStringConvertible {
    public init?(_ description: String) {
        switch description.count {
        case ed25519PublicKeyLength * 2:
            guard let decoded = try? hexDecode(description) else { return nil }
            inner = decoded

        case ed25519PublicKeyLength * 2 + ed25519PublicKeyPrefix.count:
            guard description.hasPrefix(ed25519PublicKeyPrefix) else { return nil }

            let start = description.index(description.startIndex, offsetBy: ed25519PublicKeyPrefix.count)
            guard let decoded = try? hexDecode(description[start...]) else { return nil }
            inner = decoded

        default:
            return nil
        }
    }
}
