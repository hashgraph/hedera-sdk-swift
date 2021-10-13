public final class Hbar {
  var tinybars: Int64

  public convenience init(_ tinybars: Int) {
    self.init(Int64(tinybars))
  }

  public convenience init(_ tinybars: UInt) {
    self.init(UInt64(tinybars))
  }

  public convenience init(_ tinybars: UInt64) {
    self.init(Int64(tinybars))
  }

  public init(_ tinybars: Int64) {
    self.tinybars = tinybars
  }

  public convenience init(hbars: Int) {
    self.init(hbars: Int64(hbars))
  }

  public convenience init(hbars: UInt) {
    self.init(hbars: UInt64(hbars))
  }

  public convenience init(hbars: UInt64) {
    self.init(hbars: Int64(hbars))
  }

  public convenience init(hbars: Int64) {
    self.init(hbars, HbarUnit.hbar)
  }

  public convenience init(_ value: UInt64, _ unit: HbarUnit) {
    self.init(Int64(value), unit)
  }

  public convenience init(_ value: Int64, _ unit: HbarUnit) {
    self.init(value * Int64(unit.rawValue))
  }

  func toHbarUnit(_ hbarUnit: HbarUnit) -> Double {
    Double(tinybars) / Double(hbarUnit.rawValue)
  }

  static func fromHbarUnit(_ number: Int64, _ hbarUnit: HbarUnit) -> Hbar {
    Hbar(number, hbarUnit)
  }

  func toTinybars() -> Int64 {
    tinybars
  }

  static func fromTinybars(_ tinybars: UInt64) -> Hbar {
    Hbar(tinybars / HbarUnit.hbar.rawValue)
  }
}

extension Hbar: ProtobufConvertible {
  public func toProtobuf() -> UInt64 {
    UInt64(tinybars)
  }
}

extension Hbar: CustomStringConvertible {
  public var description: String {
    tinybars > HbarUnit.hbar.rawValue
      ? "\(toHbarUnit(HbarUnit.hbar)) \(HbarUnit.hbar)"
      : "\(tinybars) \(HbarUnit.tinybar)"
  }

  public var debugDescription: String {
    description
  }
}
