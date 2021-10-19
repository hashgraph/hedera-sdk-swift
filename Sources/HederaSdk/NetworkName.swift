public enum NetworkName {
  case mainnet
  case testnet
  case previewnet
}

extension NetworkName: CustomStringConvertible, CustomDebugStringConvertible {
  public var description: String {
    switch self {
    case .mainnet:
      return "mainnet"
    case .testnet:
      return "testnet"
    case .previewnet:
      return "previewnet"
    }
  }

  public var debugDescription: String {
    description
  }
}

extension NetworkName {
  func ledgerId() -> String {
    switch self {
    case .mainnet:
      return "0"
    case .testnet:
      return "1"
    case .previewnet:
      return "2"
    }
  }
}
