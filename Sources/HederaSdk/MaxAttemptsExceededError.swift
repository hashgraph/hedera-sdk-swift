class MaxAttemptsExceededError: Error {
    public var maxAttempts: UInt

    init(_ maxAttempts: UInt) {
        self.maxAttempts = maxAttempts
    }
}