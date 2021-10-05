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

