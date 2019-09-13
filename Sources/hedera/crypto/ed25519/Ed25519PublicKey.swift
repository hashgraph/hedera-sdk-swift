import Sodium
import Foundation

let ed25519PublicKeyPrefix = "302a300506032b6570032100"
let ed25519PublicKeyLength = 32

public struct Ed25519PublicKey {
    let inner: Bytes

    private init(bytes: Bytes) {
        inner = bytes
    }

    static func from(bytes: Bytes) -> Result<Ed25519PublicKey, Error> {
        if bytes.count == ed25519PublicKeyLength {
            return .success(Ed25519PublicKey(bytes: bytes))
        } else {
            // TODO: actual error "invalid public key"
            return .failure(HederaError())
        }
    }
    
    var bytes: Bytes {
        return inner
    }
}

extension Ed25519PublicKey: PublicKey {
    public func toProtoKey() -> Proto_Key {
        var proto = Proto_Key()
        proto.ed25519 = Data(inner)
        return proto
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
