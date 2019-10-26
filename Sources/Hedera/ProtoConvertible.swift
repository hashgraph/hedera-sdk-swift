import SwiftProtobuf

protocol ProtoConvertible {
    associatedtype Proto

    func toProto() -> Proto

    init?(_ proto: Proto)
}
