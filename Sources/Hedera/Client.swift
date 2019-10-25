import Sodium
import SwiftGRPC

public typealias Node = (accountId: AccountId, address: String)

struct HederaGRPCClient {
    let fileService: Proto_FileServiceServiceClient
    let cryptoService: Proto_CryptoServiceServiceClient
    let contractService: Proto_SmartContractServiceServiceClient
}

let defaultMaxTransactionFee: UInt64 = 100_000_000

public class Client {
    var operatorId: AccountId?
    var operatorSigner: ((Bytes) -> Bytes)?

    var nodes: [AccountId: Node]
    var node: AccountId?

    var channels: [AccountId: Channel] = [:]
    var grpcClients: [AccountId: HederaGRPCClient] = [:]

    /// The default maximum fee for a transaction.
    /// This can be overridden for an individual transaction with `.setTransactionFee()`. 
    var maxTransactionFee = defaultMaxTransactionFee

    // TODO: once queries are implemented    
    // /// The maximum payment that can be automatically attached to a query.
    // /// If this is not set, payments will not be made automatically for queries.
    // /// This can be overridden for an individual query with `.setPayment()`.
    // var maxQueryPayment: UInt64?

    public init(node id: AccountId, address url: String) {
        nodes = [ id: Node(accountId: id, address: url) ]
    }
    
    public init(nodes: [(AccountId, String)]) {
        let keys = nodes.map { $0.0 }
        let values = nodes.map { Node(accountId: $0.0, address: $0.1) }
        self.nodes = Dictionary(uniqueKeysWithValues: zip(keys, values))
    }

    /// Sets the account that will be paying for transactions and queries on the network.
    /// - Parameters:
    ///   - id: Account ID
    ///   - secret: Private key that will be used to sign transactions.
    /// - Returns: Self for fluent usage.
    @discardableResult
    public func setOperator(id: AccountId, secret: Ed25519PrivateKey) -> Self {
        operatorId = id
        operatorSigner = secret.sign

        return self
    }

    /// Sets the account that will be paying for transactions and queries on the network.
    /// - Parameters:
    ///   - id: Account ID
    ///   - signer: closure that will be called to sign transactions. Useful for requesting signing from a hardware wallet that won't give you the private key.
    /// - Returns: Self for fluent usage.
    @discardableResult
    public func setOperator(id: AccountId, signer: @escaping (Bytes) -> Bytes) -> Self {
        operatorId = id
        operatorSigner = signer
        
        return self
    }
    
    /// Sets the default maximum fee for a transaction.
    /// This can be overridden for an individual transaction with `.setTransactionFee()`.
    ///
    /// - Parameters:
    ///   - max: The maximum transaction fee, in tinybars.
    ///
    /// - Returns: Self for fluent usage.
    @discardableResult
    public func setMaxTransactionFee(_ max: UInt64) -> Self {
        maxTransactionFee = max
        return self
    }
    
    // TODO: once queries are implemented
//    public mutating func setMaxQueryPayment(_ max: UInt64) -> Self {
//        maxQueryPayment = max
//        return self
//    }

    @discardableResult
    public func setNode(_ id: AccountId) -> Self {
        node = id
        return self
    }

    @discardableResult
    public func addNode(id: AccountId, address url: String) -> Self {
        nodes[id] = Node(accountId: id, address: url)
        return self
    }

    func pickNode() -> Node {
        nodes.randomElement()!.value
    }

    private func channelFor(node: Node) -> Channel {
        // TODO: what if the node is not on the client?
        if let channel = channels[node.accountId] {
            return channel
        } else {
            channels[node.accountId] = Channel(address: node.address)
            return channels[node.accountId]!
        }
    }
    
    func grpcClient(for node: Node) -> HederaGRPCClient {
        if let service = grpcClients[node.accountId] {
            return service
        } else {
            let channel = channelFor(node: node)
            let service = HederaGRPCClient(fileService: Proto_FileServiceServiceClient(channel: channel), cryptoService: Proto_CryptoServiceServiceClient(channel: channel), contractService: Proto_SmartContractServiceServiceClient(channel: channel))
            grpcClients[node.accountId] = service
            return grpcClients[node.accountId]!
        }
    }
}
