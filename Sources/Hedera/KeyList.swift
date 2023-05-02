import HederaProtobufs

/// A list of keys with an optional threshold.
public struct KeyList: ExpressibleByArrayLiteral, Equatable {
    /// The list of keys.
    public var keys: [Key]

    /// The minimum number of keys that must sign.
    ///
    /// If `nil` all keys must sign and this is a keylist (not a threshold key).
    public var threshold: Int?

    public init(arrayLiteral elements: Key...) {
        self.init(keys: Array(elements))
    }

    public init(keys: [Key], threshold: Int? = nil) {
        self.keys = keys
        self.threshold = threshold
    }
}

extension KeyList: Collection, RandomAccessCollection {
    public subscript(_ position: Int) -> Key {
        get {
            self.keys[position]
        }

        set(value) {
            self.keys[position] = value
        }
    }

    public var startIndex: Int { keys.startIndex }
    public var endIndex: Int { keys.endIndex }
}

extension KeyList: TryProtobufCodable {
    internal typealias Protobuf = Proto_KeyList

    internal init(protobuf proto: Protobuf) throws {
        self.init(keys: try .fromProtobuf(proto.keys))
    }

    internal func toProtobuf() -> Protobuf {
        .with { $0.keys = keys.toProtobuf() }
    }
}

extension KeyList {
    internal init(protobuf proto: Proto_ThresholdKey) throws {
        self.init(
            keys: try .fromProtobuf(proto.keys.keys),
            threshold: Int(proto.threshold)
        )
    }

    internal static func fromProtobuf(_ proto: Proto_ThresholdKey) throws -> Self {
        try Self(protobuf: proto)
    }

    internal func toProtobufKey() -> Proto_Key.OneOf_Key {
        if let threshold = threshold {
            return .thresholdKey(
                .with { proto in
                    proto.keys = toProtobuf()
                    proto.threshold = UInt32(threshold)
                }
            )
        }

        return .keyList(toProtobuf())
    }
}
