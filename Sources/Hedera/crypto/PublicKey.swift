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
        case .ed25519(_):
            return Ed25519PublicKey(key)
        case .keyList(_):
            return KeyList(key)
        case .contractID(_):
            return ContractId(key)
        case .thresholdKey(_):
            return ThresholdKey(key)
        case .rsa3072(_), .ecdsa384(_), .none:
            // TODO: implement rsa and ecdsa eventually
            return nil
        }
    }
}
