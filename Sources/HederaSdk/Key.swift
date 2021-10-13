import Foundation
import HederaCrypto
import HederaProtoServices

extension Key {
    static func fromProtobuf(_ key: Proto_Key) -> Key? {
        switch key.key {
        case .ed25519:
            return PublicKey.fromBytes(bytes: key.ed25519.bytes)
        case .keyList:
            var keyList = KeyList()
            return keyList.fromProtobuf(key.keyList, thresholdKey: 0)
        case .contractID:
            return ContractId(key.contractID)
        case .thresholdKey:
            var keyList = KeyList()
            return keyList.fromProtobuf(key.thresholdKey.keys, thresholdKey: key.thresholdKey.threshold)
        case .rsa3072, .ecdsa384, .none:
            return nil
        }
    }

    func toProtobufKey() -> Proto_Key? {
        var proto = Proto_Key()
        switch self {
        case let publicKey as PublicKey:
            proto.ed25519 = Data(publicKey.bytes)
            return proto
        case let keyList as KeyList:
            if keyList.getTreshold() == 0 {
                proto.keyList =  keyList.toProtobuf()!
                return proto
            } else {
                proto.thresholdKey.keys =  keyList.toProtobuf()!
                proto.thresholdKey.threshold =  keyList.getTreshold()
                return proto
            }
        case let contractId as ContractId:
            proto.contractID = contractId.toProtobuf()
            return proto
        default:
            return nil
        }
    }
}

extension KeyList {
    func fromProtobuf(_ proto: Proto_Key) -> Key? {
        guard proto.keyList.keys.count > 0 else { return nil }
        var keys = proto.keyList.keys.compactMap(Key.fromProtobuf)
        var list = KeyList.of(keys: keys)

        guard proto.keyList.keys.count == keys.count else { return nil }

        return list
    }

    func fromProtobuf(_ proto: Proto_KeyList, thresholdKey: UInt32) -> Key? {
        guard proto.keys.count > 0 else { return nil }
        var keys = proto.keys.compactMap(Key.fromProtobuf)
        var list = KeyList.of(keys: keys)

        guard proto.keys.count == keys.count else { return nil }
        list.setTreshold(threshold: thresholdKey)

        return list
    }

    func toProtobuf() -> Proto_KeyList? {
        var proto = Proto_KeyList()
        for key in self {
            proto.keys.append(key.toProtobufKey()!)
        }

        return proto
    }
}