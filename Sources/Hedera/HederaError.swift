public enum HederaError: Error {
    case networkError(HederaNetworkError)
    case queryPaymentExceedsMax
    case timedOut
    case message(String)
    case status(Int)
}

public struct HederaNetworkError: Error {
    let status: Int
    let statusMessage: String
}

func resultFromCode<T>(
    _ code: Proto_ResponseCodeEnum, 
    success: T, 
    allowUnknown: Bool = false
) -> Result<T, HederaError> {
    switch code {
        case .success, .ok:
            return .success(success)

        case .unknown where allowUnknown, 
             .receiptNotFound where allowUnknown, 
             .recordNotFound where allowUnknown:
            return .success(success)

        default: 
            return .failure(.status(code.rawValue))
    }
}
