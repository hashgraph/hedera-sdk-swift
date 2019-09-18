import Sodium
import Foundation

// TODO: this may need to go somewhere more top-level
let sodium = Sodium()

let ed25519PublicKeyPrefix = "302a300506032b6570032100"

public struct Ed25519PublicKey {
    var inner: Bytes
    
    private init(bytes: Bytes) {
        inner = bytes
    }
    
    static func from(bytes: Bytes) throws -> Ed25519PublicKey {
        if (bytes.count == 32) {
            return Ed25519PublicKey(bytes: bytes)
        } else {
            // TODO: actual error "invalid public key"
            throw HederaError()
        }
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
        return "\(ed25519PublicKeyPrefix)\(sodium.utils.bin2hex(inner)!)"
    }
}

