import Sodium

public typealias Node = (accountId: AccountId, address: String)

let defaultMaxTransactionFee: UInt64 = 100_000_000

public struct Client {
    let operatorId: AccountId
    let operatorSigner: (Bytes) -> Bytes

    let nodes: [AccountId: Node]
    var node: AccountId?

    /// The default maximum fee for a transaction.
    /// This can be overridden for an individual transaction with `.setTransactionFee()`. 
    let maxTransactionFee = defaultMaxTransactionFee

    // TODO: once queries are implemented    
    // /// The maximum payment that can be automatically attached to a query.
    // /// If this is not set, payments will not be made automatically for queries.
    // /// This can be overridden for an individual query with `.setPaymentDefault()`.
    // var maxQueryPayment: UInt64?
    
}

public struct ClientBuilder {
    var operatorId: AccountId?
    var operatorSigner: ((Bytes) -> Bytes)?
    var node: AccountId?

    public init() {}

    public mutating func setOperator(id: AccountId, secret: Ed25519PrivateKey) -> Self {
        operatorId = id
        operatorSigner = secret.sign

        return self
    }

    public mutating func setOperator(id: AccountId, signer: @escaping (Bytes) -> Bytes) -> Self {
        operatorId = id
        operatorSigner = signer

        return self
    }

    public mutating func setNode(_ id: AccountId) -> Self {
        node = id
        return self
    }
}