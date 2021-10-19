import Foundation
import HederaCrypto
import HederaProtoServices

extension Key {
    static func fromProtobuf(_ key: Proto_Key) -> Key? {
        switch key.key {
        case .ed25519:
            return PublicKey.fromBytes(bytes: key.ed25519.bytes)
        case .keyList, .thresholdKey:
            return KeyList(key)
        case .contractID:
            return ContractId(key.contractID)
        case .rsa3072, .ecdsa384, .none:
            return nil
        }
    }

    func toProtobuf() -> Proto_Key {
        if let publicKey = self as? PublicKey {
            return publicKey.toProtobufKey()
        } else if let keyList = self as? KeyList {
            return keyList.toProtobufKey()
        } else {
            fatalError("not implemented")
        }
    }
}

extension PublicKey {
    func toProtobufKey() -> Proto_Key {
        var proto = Proto_Key()
        proto.ecdsa384 = Data(bytes)
        return proto
    }
}

extension KeyList {
    public convenience init?(_ proto: Proto_Key) {
        self.init()

        switch proto.key {
        case .keyList:
            self.addAll(proto.keyList.keys.compactMap(Key.fromProtobuf))
            break
        case .thresholdKey:
            self.setThreshold(threshold: proto.thresholdKey.threshold)
            self.addAll(proto.thresholdKey.keys.keys.compactMap(Key.fromProtobuf))
            break
        default:
            break
        }

    }

    func toProtobufKey() -> Proto_Key {
        var proto = Proto_Key()

        if let threshold = self.getThreshold() {
            var thresholdKey = Proto_ThresholdKey()
            var keyList = Proto_KeyList()

            keyList.keys = getKeys().map { $0.toProtobuf() }
            thresholdKey.threshold = threshold
            thresholdKey.keys = keyList
            proto.thresholdKey = thresholdKey
        } else {
            var keyList = Proto_KeyList()
            keyList.keys = getKeys().map { $0.toProtobuf() }
            proto.keyList = keyList
        }

        return proto
    }
}
