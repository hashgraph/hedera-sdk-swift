import Sodium

let ed25519PrivateKeyPrefix = "302e020100300506032b657004220420"
let ed25519PrivateKeyLength = 32
let combinedEd25519KeyLength = 64

// TODO: how to handle error possibilities???
struct InvalidKeyBytes: Error {}

public struct Ed25519PrivateKey {
    var inner: Bytes

    private init(bytes: Bytes) {
        inner = bytes
    }

    public static func from(bytes: Bytes) -> Result<Ed25519PrivateKey, Error> {
        if bytes.count == ed25519PrivateKeyLength {
            return .success(Ed25519PrivateKey(bytes: bytes))
        } else if bytes.count == combinedEd25519KeyLength {
            return .success(Ed25519PrivateKey(bytes: Bytes(bytes.prefix(ed25519PrivateKeyLength))))
        }
        return .failure(InvalidKeyBytes())
    }

    var bytes: Bytes {
        return inner
    }

    public static func generate() -> Ed25519PrivateKey {
        return Ed25519PrivateKey(bytes: sodium.box.keyPair()!.secretKey)
    }

    public func getPublicKey() -> Ed25519PublicKey {
        return try! Ed25519PublicKey.from(bytes: sodium.box.keyPair(seed: inner)!.publicKey).get()
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
            // This cannot fail to decode
            // swiftlint:disable:next force_try
            inner = try! Ed25519PrivateKey.from(bytes: try! hexDecode(description).get()).get().inner
        case ed25519PrivateKeyLength * 2 + ed25519PrivateKeyPrefix.count: // DER encoded key
            if description.hasPrefix(ed25519PrivateKeyPrefix) {
                let range = description.index(description.startIndex, offsetBy: ed25519PrivateKeyPrefix.count)...
                // This cannot fail to decode
                // swiftlint:disable:next force_try
                inner = try! Ed25519PrivateKey.from(bytes: try! hexDecode(description[range]).get()).get().inner
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}
