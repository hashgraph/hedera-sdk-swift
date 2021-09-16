public final class Hbar {
    var tinybars: UInt64

    init(_ tinybars: UInt64) {
        self.tinybars = tinybars
    }

    func toTinybars() -> UInt64 {
        tinybars
    }
}

extension Hbar: ProtobufConvertible {
    func toProtobuf() -> UInt64 {
        tinybars
    }
}