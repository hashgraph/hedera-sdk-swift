import Foundation

enum Backoff {
    static let receiptInitialDelay: UInt32 = 1
    static let receiptRetryDelay: TimeInterval = 0.5

    static func getDelayUs(startTime: Date, attempt: UInt8) -> UInt32? {
        // exponential backoff algorithm:
        // next delay is some constant * rand(0, 2 ** attempt - 1)
        let delay = Backoff.receiptRetryDelay
            * Double.random(in: 0..<Double((1 << attempt)))

        // if the next delay will put us past the valid duration we should stop trying
        let validDuration: TimeInterval = 2 * 60
        let expireInstant = startTime.addingTimeInterval(validDuration)
        if Date(timeIntervalSinceNow: delay).compare(expireInstant) == .orderedDescending {
            return nil
        }

        // converting from seconds to microseconds
        return UInt32(delay * 1000000)
    }
}