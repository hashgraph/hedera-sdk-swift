import Sodium
import Foundation

let ed25519PublicKeyPrefix = "302a300506032b6570032100"
let ed25519PublicKeyLength = 32

public final class Ed25519PublicKey: PublicKey {
    private let inner: Bytes

    // Overriding CustomStringConvertible and CustomDebugStringConvertible
    override public var description: String {
        "\(ed25519PublicKeyPrefix)\(sodium.utils.bin2hex(bytes)!)"
    }
    override public var debugDescription: String {
        description
    }
    
    public init?(bytes: Bytes) {
        if bytes.count == ed25519PublicKeyLength {
            inner = bytes
            super.init()
        } else {
            return nil
        }
    }
    
    required convenience init?(_ proto: Proto_Key) {
        self.init(bytes: Bytes(proto.ed25519))
    }

    var bytes: Bytes {
        inner
    }

    /// Verify the detached signature of a message with this public key
    func verify(signature: Bytes, of message: Bytes) -> Bool {
        sodium.sign.verify(message: message, publicKey: inner, signature: signature)
    }
    
    override func toProto() -> Proto_Key {
        var proto = Proto()
        proto.ed25519 = Data(bytes)
        return proto
    }
}

extension Ed25519PublicKey: LosslessStringConvertible {
    public convenience init?(_ description: String) {
        switch description.count {
        case ed25519PublicKeyLength * 2:
            guard let decoded = sodium.utils.hex2bin(description) else { return nil }
            self.init(bytes: decoded)

        case ed25519PublicKeyLength * 2 + ed25519PublicKeyPrefix.count:
            guard description.hasPrefix(ed25519PublicKeyPrefix) else { return nil }

            let start = description.index(description.startIndex, offsetBy: ed25519PublicKeyPrefix.count)
            guard let decoded = sodium.utils.hex2bin(String(description[start...])) else { return nil }
            self.init(bytes: decoded)

        default:
            return nil
        }
    }
}

// We get this for free cause the same functions are defined in PublicKey and we override them elsewhere
extension Ed25519PublicKey: ProtoConvertible {}
