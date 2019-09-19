import Sodium

let ed25519PrivateKeyPrefix = "302e020100300506032b657004220420"

// TODO
public struct Ed25519PrivateKey {
    var inner: Bytes

    private init(bytes: Bytes) {
        inner = bytes
    }

    public static func from(bytes: Bytes) -> Ed25519PrivateKey {
        // TODO: check length first
        return Ed25519PrivateKey(bytes: bytes)
    }

    public static func generate() -> Ed25519PrivateKey {
        return Ed25519PrivateKey(bytes: sodium.box.keyPair()!.secretKey)
    }

    // TODO
    // func getPublicKey() -> Ed25519PublicKey {}
}
