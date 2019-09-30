import Sodium
import SwiftGRPC

public typealias Node = (accountId: AccountId, address: String)

let defaultMaxTransactionFee: UInt64 = 100_000_000

public struct Client {
    var operatorId: AccountId?
    var operatorSigner: ((Bytes) -> Bytes)?

    var nodes: [AccountId: Node]
    var node: AccountId?

    var channels: [AccountId: Channel] = [:]

    /// The default maximum fee for a transaction.
    /// This can be overridden for an individual transaction with `.setTransactionFee()`. 
    var maxTransactionFee = defaultMaxTransactionFee

    // TODO: once queries are implemented    
    // /// The maximum payment that can be automatically attached to a query.
    // /// If this is not set, payments will not be made automatically for queries.
    // /// This can be overridden for an individual query with `.setPaymentDefault()`.
    // var maxQueryPayment: UInt64?

    public init(node id: AccountId, address url: String) {
        nodes = [ id: Node(accountId: id, address: url) ]
    }

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

    public mutating func addNode(id: AccountId, address url: String) -> Self {
        nodes[id] = Node(accountId: id, address: url)
        return self
    }

    func pickNode() -> Node {
        nodes.randomElement()!.value
    }

    mutating func channelFor(node: Node) -> Channel {
        // TODO: what if the node is not on the client?
        if let channel = channels[node.accountId] {
            return channel
        } else {
            channels[node.accountId] = Channel(address: node.address)
            return channels[node.accountId]!
        }
    }
}
