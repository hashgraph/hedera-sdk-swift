public typealias Node = (accountId: AccountId, address: String)

let defaultMaxTransactionFee = 100_000

public struct Client {
    let operatorId: AccountId
    let operatorKey: Ed25519PrivateKey

    let nodes: [AccountId: Node]
}

public struct ClientBuilder {
    var operatorId: AccountId?
    var operatorKey: Ed25519PrivateKey?
    var node: Node?
}