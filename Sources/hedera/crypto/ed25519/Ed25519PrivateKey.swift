import Sodium

let ed25519PrivateKeyPrefix = "302e020100300506032b657004220420"
let ed25519PrivateKeyLength = 32
let combinedEd25519KeyLength = 64

// TODO: how to handle error possibilities???
struct InvalidKeyBytes: Error {}
struct InvalidKeyString: Error {}

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

    // Recover from a hex encoded string. Does not support key derivation.
    public static func from(string: String) -> Result<Ed25519PrivateKey, Error> {
        switch string.count {
        case ed25519PrivateKeyLength * 2, combinedEd25519KeyLength * 2: // lone key, or combined key
            // This cannot fail to decode
            // swiftlint:disable:next force_try
            return from(bytes: try! hexDecode(string).get())
        case ed25519PrivateKeyLength * 2 + ed25519PrivateKeyPrefix.count: // DER encoded key
            if string.hasPrefix(ed25519PrivateKeyPrefix) {
                // This cannot fail to decode
                // swiftlint:disable:next force_try
                return from(bytes: try! hexDecode(string[string.index(string.startIndex, offsetBy: ed25519PrivateKeyPrefix.count)...]).get())
            } else {
                return .failure(InvalidKeyString())
            }
        default:
            return .failure(InvalidKeyString())
        }
    }

    public static func generate() -> Ed25519PrivateKey {
        return Ed25519PrivateKey(bytes: sodium.box.keyPair()!.secretKey)
    }

    // TODO
    public func getPublicKey() -> Ed25519PublicKey {
        return try! Ed25519PublicKey.from(bytes: sodium.box.keyPair(seed: inner)!.publicKey).get()
    }
}
