import SwiftProtobuf

protocol ProtobufConvertible {
  associatedtype Protobuf

  func toProtobuf() -> Protobuf

  init?(_ proto: Protobuf)
}
