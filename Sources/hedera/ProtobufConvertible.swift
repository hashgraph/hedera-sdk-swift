import SwiftProtobuf

protocol ProtobufConvertible {
    associatedtype Proto

    func toProto() -> Proto

    init?(_ proto: Proto)
}