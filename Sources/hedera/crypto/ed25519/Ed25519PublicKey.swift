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

// TODO: Make this not explode on bad hex chars
extension Ed25519PublicKey: LosslessStringConvertible {
    public init?(_ description: String) {
        switch description.count {
        case ed25519PublicKeyLength * 2:
            // This cannot fail
            // swiftlint:disable:next force_try
            inner = try! hexDecode(description).get()
        case ed25519PublicKeyLength * 2 + ed25519PublicKeyPrefix.count:
            let start = description.index(description.startIndex, offsetBy: ed25519PublicKeyPrefix.count)
            // This cannot fail
            // swiftlint:disable:next force_try
            inner = try! hexDecode(description[start...]).get()
        default:
            return nil
        }
    }
}
