public final class KeyList: PublicKey {
    var keys: [PublicKey]

    override public init() {
        keys = []

        super.init()
    }

    required init?(_ proto: Proto_Key) {
        guard proto.keyList.keys.count > 0 else { return nil }
        keys = proto.keyList.keys.compactMap(PublicKey.fromProto)

        // Don't want to silently throw away keys we don't recognize
        guard proto.keyList.keys.count == keys.count else { return nil }

        super.init()
    }

    init?(_ proto: Proto_KeyList) {
        guard proto.keys.count > 0 else { return nil }
        keys = proto.keys.compactMap(PublicKey.fromProto)

        // Don't want to silently throw away keys we don't recognize
        guard proto.keys.count == keys.count else { return nil }
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

    @discardableResult
    public func add(_ key: PublicKey) -> Self {
        keys.append(key)

        return self
    }

    @discardableResult
    public func addAll(_ keys: [PublicKey]) -> Self {
        self.keys.append(contentsOf: keys)

        return self
    }
}
