public class Query<S: MethodDescriptor, O: ProtobufConvertible> : Executable<O> {
    var maxQueryPayment: Hbar?
    var queryPayment: Hbar?

    @discardableResult
    public func setMaxQueryPayment(_ maxQueryPayment: Hbar) -> Self {
        self.maxQueryPayment = maxQueryPayment
        return self
    }

    @discardableResult
    public func setQueryPayment(_ queryPayment: Hbar) -> Self {
        self.queryPayment = queryPayment
        return self
    }

    func isPaymentRequired() -> Bool {
        true
    }

    func execute(_ client: Client) {
        let descriptor = S.getMethodDescriptor;
    }
}