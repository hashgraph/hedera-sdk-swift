public enum TokenSupplyType: Int {
  case TokenSupplyTypeInfinite = 0
  case TokenSupplyTypeFinite = 1
}

extension TokenSupplyType: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch self {
    case .TokenSupplyTypeInfinite:
      return "TOKEN_SUPPLY_TYPE_INFINITE"
    case .TokenSupplyTypeFinite:
      return "TOKEN_SUPPLY_TYPE_FINITE"
    }
  }

  public var debugDescription: String {
    description
  }
}
