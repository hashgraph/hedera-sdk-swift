import Sodium

let ed25519PrivateKeyPrefix = "302e020100300506032b657004220420"
let ed25519PrivateKeyLength = 32
let combinedEd25519KeyLength = 64

// TODO: init using a pem file

public struct Ed25519PrivateKey {
    private let inner: Sign.KeyPair

    /// Generate a new private key
    public init() {
        inner = sodium.sign.keyPair()!
    }

    /// Initialize a private key from bytes
    ///
    /// Bytes must be either a private key or a combined private/public key pair
    public init?(bytes: Bytes) {
        if bytes.count == ed25519PrivateKeyLength {
            inner = sodium.sign.keyPair(seed: bytes)!
        } else if bytes.count == combinedEd25519KeyLength {
            inner = sodium.sign.keyPair(seed: Bytes(bytes.prefix(ed25519PrivateKeyLength)))!
        } else {
            // Invalid key length
            return nil
        }
    }

    /// The byte representation of the private key
    public var bytes: Bytes {
        inner.secretKey
    }

    public var publicKey: Ed25519PublicKey {
        Ed25519PublicKey(bytes: inner.publicKey)!
    }

    /// Compute a detached signature for the given message
    func sign(message bytes: Bytes) -> Bytes {
        sodium.sign.signature(message: bytes, secretKey: inner.secretKey)!
    }
}

extension Ed25519PrivateKey: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "\(ed25519PrivateKeyPrefix)\(sodium.utils.bin2hex(bytes)!)"
    }

    public var debugDescription: String {
        description
    }
}

extension Ed25519PrivateKey: LosslessStringConvertible {
    /// Recover from a hex encoded string. Does not support key derivation.
    public init?(_ description: String) {
        switch description.count {
        case ed25519PrivateKeyLength * 2, combinedEd25519KeyLength * 2: // lone key, or combined key
            guard let decoded = sodium.utils.hex2bin(description) else { return nil }
            self = Ed25519PrivateKey(bytes: decoded)!

        case ed25519PrivateKeyLength * 2 + ed25519PrivateKeyPrefix.count: // DER encoded key
            guard description.hasPrefix(ed25519PrivateKeyPrefix) else { return nil }

            let range = description.index(description.startIndex, offsetBy: ed25519PrivateKeyPrefix.count)...
            guard let decoded = sodium.utils.hex2bin(String(description[range])) else { return nil }
            self = Ed25519PrivateKey(bytes: decoded)!

        default:
            return nil
        }
    }
}
