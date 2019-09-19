import Sodium

let ed25519PrivateKeyPrefix = "302e020100300506032b657004220420"
let ed25519PrivateKeyLength = 32
let combinedEd25519KeyLength = 64

// TODO
public struct Ed25519PrivateKey {
    var inner: Bytes

    private init(bytes: Bytes) {
        inner = bytes
    }

    public static func from(bytes: Bytes) -> Optional<Ed25519PrivateKey> {
        if (bytes.count == ed25519PrivateKeyLength) {
            return Ed25519PrivateKey(bytes: bytes)
        } else if (bytes.count == combinedEd25519KeyLength) {
            return Ed25519PrivateKey(bytes: Bytes(bytes.prefix(ed25519PrivateKeyLength)))
        }
        return nil
    }

    // Recover from a hex encoded string. Does not support key derivation.
    public static func from(string: String) -> Optional<Ed25519PrivateKey> {
        switch string.count {
        case 64: // lone private key
            fallthrough
        case 128: // private key + public key
            return from(bytes: hexDecode(string)!)
        case 96:
            if string.startsWith(ed25519PrivateKeyPrefix) {
                return from(bytes: string.suffix(32))
            }
        default:
            return nil    
        }
    }

    public static func generate() -> Ed25519PrivateKey {
        return Ed25519PrivateKey(bytes: sodium.box.keyPair()!.secretKey)
    }

    // TODO
    // func getPublicKey() -> Ed25519PublicKey {}
}

func hexDecode(_ string: String) -> Optional<Bytes> {
    if hex.length % 2 != 0 {
        // error, it must be even length
    }

    let bytesLen = string.count / 2;
    var bytes = Bytes(repeating: 0, count: bytesLen);
    for i in 0...bytesLen {
        bytes[i] = Int(string.slice(i*2, i*2+2), radix: 16)
    }

    return bytes
}