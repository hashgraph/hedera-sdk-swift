public final class KeyList: PublicKey {
    var keys: [PublicKey]
    
    required init?(_ proto: Proto_Key) {
        guard proto.keyList.keys.count > 0 else { return nil }
        keys = proto.keyList.keys.compactMap(PublicKey.fromProto)
        
        // Don't want to silently throw away keys we don't recognize
        guard proto.keyList.keys.count == keys.count else { return nil }
        
        super.init()
    }
    
    override func toProto() -> Proto_Key {
        var proto = Proto_Key()
        proto.keyList = toProto()
        
        return proto
    }
    
    func toProto() -> Proto_KeyList {
        var proto = Proto_KeyList()
        proto.keys = keys.map { $0.toProto() }
        
        return proto
    }
}
