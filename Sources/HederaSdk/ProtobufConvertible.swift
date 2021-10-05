import SwiftProtobuf

public protocol ProtobufConvertible {
  associatedtype Protobuf

  func toProtobuf() -> Protobuf

  init?(_ proto: Protobuf)
}
