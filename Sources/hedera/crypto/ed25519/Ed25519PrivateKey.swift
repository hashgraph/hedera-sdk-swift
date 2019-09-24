import Sodium

let ed25519PrivateKeyPrefix = "302e020100300506032b657004220420"
let ed25519PrivateKeyLength = 32
let combinedEd25519KeyLength = 64

public struct Ed25519PrivateKey {
    private let inner: Bytes

    public init?(bytes: Bytes) {
        if bytes.count == ed25519PrivateKeyLength {
            inner = bytes
        } else if bytes.count == combinedEd25519KeyLength {
            inner = Bytes(bytes.prefix(ed25519PrivateKeyLength))
        } else {
            // Invalid key length
            return nil
        }
    }

    public var bytes: Bytes {
        return inner
    }

    public static func generate() -> Ed25519PrivateKey {
        return Ed25519PrivateKey(bytes: sodium.sign.keyPair()!.secretKey)!
    }

    public var publicKey: Ed25519PublicKey {
        return Ed25519PublicKey(bytes: sodium.sign.keyPair(seed: inner)!.publicKey)!
    }
}

extension Ed25519PrivateKey: CustomStringConvertible {
    public var description: String {
        return hexEncode(bytes: inner, prefixed: ed25519PrivateKeyPrefix)
    }
}

extension Ed25519PrivateKey: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

extension Ed25519PrivateKey: LosslessStringConvertible {
    // Recover from a hex encoded string. Does not support key derivation.
    public init?(_ description: String) {
        switch description.count {
        case ed25519PrivateKeyLength * 2, combinedEd25519KeyLength * 2: // lone key, or combined key
            guard let decoded = try? hexDecode(description) else { return nil }
            inner = decoded

        case ed25519PrivateKeyLength * 2 + ed25519PrivateKeyPrefix.count: // DER encoded key
            guard description.hasPrefix(ed25519PrivateKeyPrefix) else { return nil }
    
            let range = description.index(description.startIndex, offsetBy: ed25519PrivateKeyPrefix.count)...
            guard let decoded = try? hexDecode(description[range]) else { return nil }
            inner = decoded

        default:
            return nil
        }
    }
}
