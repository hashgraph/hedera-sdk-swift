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
        inner
    }

    func verify(signature: Bytes, of message: Bytes) -> Bool {
        sodium.sign.verify(message: message, publicKey: inner, signature: signature)
    }
}

extension Ed25519PublicKey: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
         hexEncode(bytes: inner, prefixed: ed25519PublicKeyPrefix)
    }
    
    public var debugDescription: String {
        description
    }
}

extension Ed25519PublicKey: LosslessStringConvertible {
    public init?(_ description: String) {
        switch description.count {
        case ed25519PublicKeyLength * 2:
            guard let decoded = try? hexDecode(description) else { return nil }
            inner = decoded

        case ed25519PublicKeyLength * 2 + ed25519PublicKeyPrefix.count:
            guard description.hasPrefix(ed25519PublicKeyPrefix) else { return nil }

            let start = description.index(description.startIndex, offsetBy: ed25519PublicKeyPrefix.count)
            guard let decoded = try? hexDecode(description[start...]) else { return nil }
            inner = decoded

        default:
            return nil
        }
    }
}

extension Ed25519PublicKey: ProtoConvertible {
    typealias Proto = Proto_Key
    
    func toProto() -> Proto_Key {
        var proto = Proto()
        proto.ed25519 = Data(bytes)
        return proto
    }

    init?(_ proto: Proto) {
        self = Ed25519PublicKey(bytes: Bytes(proto.ed25519))!
    }
}