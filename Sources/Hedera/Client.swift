import Sodium
import SwiftGRPC

public typealias Node = (accountId: AccountId, address: String)

typealias HederaGRPCClient = (fileService: Proto_FileServiceServiceClient,
    cryptoService: Proto_CryptoServiceServiceClient,
    contractService: Proto_SmartContractServiceServiceClient)

let defaultMaxTransactionFee: UInt64 = 100_000_000

public class Client {
    var `operator`: Operator?

    var nodes: [AccountId: Node]
    var node: Node?

    var channels: [AccountId: Channel] = [:]
    var grpcClients: [AccountId: HederaGRPCClient] = [:]

    /// The default maximum fee for a transaction.
    /// This can be overridden on an individual transaction with `setMaxTransactionFee()`.
    var maxTransactionFee = defaultMaxTransactionFee

    // TODO: once queries are implemented    
    // /// The maximum payment that can be automatically attached to a query.
    // /// If this is not set, payments will not be made automatically for queries.
    // /// This can be overridden for an individual query with `.setPayment()`.
    var maxQueryPayment: UInt64?

    public init(node id: AccountId, address url: String) {
        nodes = [ id: Node(accountId: id, address: url) ]
    }

    public init(nodes: [(AccountId, String)]) {
        let keys = nodes.map { $0.0 }
        let values = nodes.map { Node(accountId: $0.0, address: $0.1) }
        self.nodes = Dictionary(uniqueKeysWithValues: zip(keys, values))
    }

    /// Sets the account that will be paying for transactions and queries on the network.
    /// - Returns: Self for fluent usage.
    @discardableResult
    public func setOperator(_ operator: Operator) -> Self {
        self.`operator` = `operator`
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

    /// Sets the default maximum fee for a query.
    /// This can be overridden for an individual query with `.setPayment()`.
    ///
    /// - Parameters:
    ///   - max: The maximum query fee, in tinybars.
    ///
    /// - Returns: Self for fluent usage.
    @discardableResult
    public func setMaxQueryPayment(_ max: UInt64) -> Self {
       maxQueryPayment = max
       return self
    }

    @discardableResult
    public func setNode(_ id: AccountId) -> Self {
        node = nodes[id]
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

    // FIXME: Return AccountId when `executeForReceipt` is implemented
    public func createAccount(key: Ed25519PublicKey, balance: UInt64) throws -> AccountId {
        return try AccountCreateTransaction(client: self)
            .setInitialBalance(balance)
            .setKey(key)
            .build()
            .executeForReceipt()
            .accountId!
    }

    // FIXME: Get TransactionId from `TransactionReceipt` when `executeForReceipt` is implemented
    public func transferCryptoTo(recipient: AccountId, amount: UInt64) throws -> TransactionId {
        return try CryptoTransferTransaction(client: self)
            .add(sender: self.operator!.id, amount: amount)
            .add(recipient: recipient, amount: amount)
            .build()
            .execute()
    }

    // FIXME: Doc comments
    public func getAccountBalance() throws -> UInt64 {
        return try AccountBalanceQuery(client: self)
            .setAccount(self.operator!.id)
            .execute()
    }

    // FIXME: Doc comments
    public func getAccountInfo() throws -> AccountInfo {
        return try AccountInfoQuery(client: self)
            .setAccount(self.operator!.id)
            .execute()
    }

    private func channelFor(node: Node) -> Channel {
        // TODO: what if the node is not on the client?
        if let channel = channels[node.accountId] {
            return channel
        } else {
            channels[node.accountId] = Channel(address: node.address, secure: false)
            return channels[node.accountId]!
        }
    }

    func grpcClient(for node: Node) -> HederaGRPCClient {
        if let service = grpcClients[node.accountId] {
            return service
        } else {
            let channel = channelFor(node: node)
            let service = HederaGRPCClient(
                fileService: Proto_FileServiceServiceClient(channel: channel),
                cryptoService: Proto_CryptoServiceServiceClient(channel: channel),
                contractService: Proto_SmartContractServiceServiceClient(channel: channel))
            grpcClients[node.accountId] = service
            return grpcClients[node.accountId]!
        }
    }
}
