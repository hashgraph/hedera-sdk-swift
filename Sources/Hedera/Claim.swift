import Foundation
import Sodium

public final class Claim: ProtoConvertible {
    let id: AccountId
    let hash: Bytes
    let keys: KeyList

    init(_ proto: Proto_Claim) {
        id = AccountId(proto.accountID)
        hash = Bytes(proto.hash)
        keys = KeyList(proto.keys)!
    }

    func toProto() -> Proto_Claim {
        var proto = Proto_Claim()
        proto.accountID = id.toProto()
        proto.hash = Data(hash)
        proto.keys = keys.toProto()
        return proto
    }
}
