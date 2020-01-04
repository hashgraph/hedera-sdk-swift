public enum HederaError: Error {
    case networkError(HederaNetworkError)
    case queryPaymentExceedsMax
    case message(String)
}

public struct HederaNetworkError: Error {
    let status: Int
    let statusMessage: String
}
