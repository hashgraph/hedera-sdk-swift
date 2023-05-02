import Foundation
import HederaProtobufs

/// A duration with second precision.
///
/// ## Units
public struct Duration: Sendable {
    public let seconds: UInt64

    public init(seconds: UInt64) {
        self.seconds = seconds
    }

    /// Create a Duration from a given number of days.
    public static func days(_ days: UInt64) -> Self {
        .hours(days * 24)
    }

    /// Create a Duration from a given number of hours.
    public static func hours(_ hours: UInt64) -> Self {
        .minutes(hours * 60)
    }

    /// Create a Duration from a given number of minutes.
    public static func minutes(_ minutes: UInt64) -> Self {
        .seconds(minutes * 60)
    }

    /// Create a Duration from a given number of seconds.
    public static func seconds(_ seconds: UInt64) -> Self {
        Self(seconds: seconds)
    }
}

extension Duration: ProtobufCodable {
    internal typealias Protobuf = Proto_Duration

    internal init(protobuf proto: Protobuf) {
        seconds = UInt64(proto.seconds)
    }

    internal func toProtobuf() -> Protobuf {
        .with { proto in proto.seconds = Int64(seconds) }
    }
}
