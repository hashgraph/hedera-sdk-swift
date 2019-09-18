import Foundation
import Sodium

// TODO
public struct HederaError: Error {}

public protocol PublicKey {
    func toProtoKey() -> Proto_Key
}

extension PublicKey {
    static func from(proto key: Proto_Key) throws -> PublicKey {
        switch key.key! {
        case let .ed25519(data):
            return try! Ed25519PublicKey.from(bytes: Bytes(data))
        // TODO: case .contractID()
        default:
            // TODO: Unhandled Key Case error
            throw HederaError()
        }
    }
    
    // TODO
    // static func from(string: String) -> PublicKey {}
}
