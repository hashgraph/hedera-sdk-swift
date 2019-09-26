import SwiftProtobuf
import Foundation

// We can't have Date conform to ProtoConvertible because Date can be used
// for _both_ `Proto_Timestamp` and `Proto_TimestampSeconds`
extension Date {
    static let nanosPerSecond: Double = 1_000_000_000

    var wholeSecondsSince1970: Int64 {
        Int64(timeIntervalSince1970)
    }

    var nanosSinceSecondSince1970: Int32 {
        Int32(timeIntervalSince1970.truncatingRemainder(dividingBy: 1) * Date.nanosPerSecond)
    }

    func toProto() -> Proto_Timestamp {
        var proto = Proto_Timestamp()
        proto.seconds = wholeSecondsSince1970
        proto.nanos = nanosSinceSecondSince1970

        return proto
    }

    func toProto() -> Proto_TimestampSeconds {
        var proto = Proto_TimestampSeconds()
        proto.seconds = wholeSecondsSince1970

        return proto
    }

    init(_ proto: Proto_Timestamp) {
        let seconds = Double(proto.seconds) + (Double(proto.nanos) / Date.nanosPerSecond)

        self = Date(timeIntervalSince1970: seconds)
    }

    init(_ proto: Proto_TimestampSeconds) {
        let seconds = Double(proto.seconds)

        self = Date(timeIntervalSince1970: seconds)
    }
}

extension Date: LosslessStringConvertible {
    public init?(_ description: String) {
        let parts = description.split(separator: ".")
        guard parts.count == 2 else { return nil }

        guard let seconds = Int64(parts[parts.startIndex]) else { return nil }
    guard let nanos = Int32(parts[parts.startIndex.advanced(by: 1)]) else { return nil }

        self = Date(timeIntervalSince1970: Double(seconds) + (Double(nanos) / Date.nanosPerSecond))
    }
}


// TODO: move to its own file?
extension TimeInterval: ProtoConvertible {
    typealias Proto = Proto_Duration

    func toProto() -> Proto {
        var proto = Proto()
        proto.seconds = Int64(self)

        return proto
    }

    init?(_ proto: Proto) {
        self = Double(proto.seconds)
    }
}