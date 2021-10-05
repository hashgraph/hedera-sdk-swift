public final class Hbar {
  var tinybars: UInt64

  public init(_ tinybars: UInt64) {
    self.tinybars = tinybars
  }

  func toTinybars() -> UInt64 {
    tinybars
  }
}

extension Hbar: ProtobufConvertible {
  public func toProtobuf() -> UInt64 {
    tinybars
  }
}

extension Hbar: CustomStringConvertible {
  public var description: String {
    String(tinybars)
  }

  public var debugDescription: String {
    description
  }
}
