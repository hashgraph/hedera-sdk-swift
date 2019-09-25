import SwiftProtobuf
import Foundation

// We can't have Date conform to ProtobufConvertible because Date can be used 
// for _both_ `Proto_Timestamp` and `Proto_TimestampSeconds`
extension Date {
    static let nanosPerSecond: Double = 1_000_000_000

    func toProto() -> Proto_Timestamp {
        var proto = Proto_Timestamp()
        proto.seconds = Int64(timeIntervalSince1970)
        proto.nanos = Int32(timeIntervalSince1970.truncatingRemainder(dividingBy: 1) * Date.nanosPerSecond)

        return proto
    }

    func toProto() -> Proto_TimestampSeconds {
        var proto = Proto_TimestampSeconds()
        proto.seconds = Int64(timeIntervalSince1970)

        return proto
    }
    
    init?(_ proto: Proto_Timestamp) {
        let seconds = Double(proto.seconds) + (Double(proto.nanos) / Date.nanosPerSecond)
        
        self = Date(timeIntervalSince1970: seconds)
    }

    init?(_ proto: Proto_TimestampSeconds) {
        let seconds = Double(proto.seconds)

        self = Date(timeIntervalSince1970: seconds)
    }
    
}