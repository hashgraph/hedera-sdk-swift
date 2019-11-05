public class PublicKey: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String { "Don't use PublicKey directly" }
    public var debugDescription: String { "Don't use PublicKey directly" }
    
    init() {}
    
    // These are the same functions as ProtoConvertible
    required init?(_ proto: Proto_Key) {}
    func toProto() -> Proto_Key {
        fatalError("Don't use PublicKey directly")
    }

    static func fromProto(_ key: Proto_Key) -> PublicKey? {
        switch key.key {
        case .ed25519:
            return Ed25519PublicKey(key)
        case .keyList:
            return KeyList(key)
        case .contractID:
            return ContractId(key)
        case .thresholdKey:
            return ThresholdKey(key)
        case .rsa3072, .ecdsa384, .none:
            // TODO: implement rsa and ecdsa eventually
            return nil
        }
    }
}
