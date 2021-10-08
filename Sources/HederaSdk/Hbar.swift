public final class Hbar {
  var tinybars: UInt64

  public init(_ hbars: UInt64) {
    tinybars = hbars * HbarUnit.hbar.rawValue
  }

  func toHbarUnit(_ hbarUnit: HbarUnit) -> UInt64 {
    tinybars/hbarUnit.rawValue
  }

  static func fromHbarUnit(_ number: UInt64, _ hbarUnit: HbarUnit) -> Hbar {
    Hbar(number * hbarUnit.rawValue)
  }

  func toTinybars() -> UInt64 {
    tinybars
  }

  static func fromTinybars(_ tinybars: UInt64) -> Hbar {
    Hbar(tinybars/HbarUnit.hbar.rawValue)
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
