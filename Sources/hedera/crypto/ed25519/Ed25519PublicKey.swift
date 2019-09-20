import Sodium
import Foundation

let ed25519PublicKeyPrefix = "302a300506032b6570032100"

public struct Ed25519PublicKey {
    var inner: Bytes

    private init(bytes: Bytes) {
        inner = bytes
    }

    static func from(bytes: Bytes) -> Result<Ed25519PublicKey, Error> {
        if bytes.count == 32 {
            return .success(Ed25519PublicKey(bytes: bytes))
        } else {
            // TODO: actual error "invalid public key"
            return .failure(HederaError())
        }
    }
    
    static func from(string: String) -> Result<Ed25519PublicKey, Error> {
        // TODO: actually implement this
        return .failure(HederaError())
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
