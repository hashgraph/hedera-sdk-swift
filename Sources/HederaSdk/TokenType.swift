public enum TokenType: Int {
  case TokenTypeFungibleCommon = 0
  case TokenTypeNonFungibleUnique = 1
}

extension TokenType: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch self {
    case .TokenTypeFungibleCommon:
      return "TOKEN_TYPE_FUNGIBLE_COMMON"
    case .TokenTypeNonFungibleUnique:
      return "TOKEN_TYPE_NON_FUNGIBLE_UNIQUE"
    }
  }

  public var debugDescription: String {
    description
  }
}
