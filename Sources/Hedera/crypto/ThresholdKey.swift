public final class ThresholdKey: PublicKey {
    let threshold: UInt32
    var keys: [PublicKey]
    
    required init?(_ proto: Proto_Key) {
        guard proto.thresholdKey.hasKeys else { return nil }
        threshold = proto.thresholdKey.threshold
        keys = proto.thresholdKey.keys.keys.compactMap(PublicKey.fromProto)
        
        // Don't want to silently throw away keys we don't recognize
        guard proto.thresholdKey.keys.keys.count == keys.count else { return nil }

        super.init()
    }
    
    override func toProto() -> Proto_Key {
        var proto = Proto_Key()
        proto.thresholdKey = toProto()

        return proto
    }

    func toProto() -> Proto_ThresholdKey {
        var proto = Proto_ThresholdKey()
        proto.keys = Proto_KeyList()
        proto.keys.keys = keys.map { $0.toProto() }

        return proto
    }
}
