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

    /// The maximum payment that can be automatically attached to a query.
    /// If this is not set, payments will not be made automatically for queries.
    /// This can be overridden for an individual query with `.setPayment()`.
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

    /// Creates an account with the given `key` and an initial balance of `balance`.
    /// - Parameters:
    ///   - key: The public key to use for account Creation.
    ///   - balance: The initial balance of the account.
    /// - Returns: The transaction's ID.
    public func createAccount(key: Ed25519PublicKey, balance: UInt64) -> Result<AccountId, HederaError> {
        AccountCreateTransaction(client: self)
            .setInitialBalance(balance)
            .setKey(key)
            .build()
            .executeForReceipt()
            .map { $0.accountId! }
    }

    /// Sends `amount` of tiny bar to `recipient`.
    /// - Parameters:
    ///   - recipient: The recipient of the crypto.
    ///   - amount: The amount of tiny bar to send.
    /// - Returns: The transaction's ID.
    public func transferCryptoTo(recipient: AccountId, amount: UInt64) -> Result<TransactionId, HederaError> {
        CryptoTransferTransaction(client: self)
            .add(sender: self.operator!.id, amount: amount)
            .add(recipient: recipient, amount: amount)
            .build()
            .execute()
    }

    /// Gets the balance of the operator's account in tiny bars.
    /// - Returns: The operator's account balance.
    public func getAccountBalance() -> Result<UInt64, HederaError> {
        AccountBalanceQuery(client: self)
            .setAccount(self.operator!.id)
            .execute()
    }

    /// Gets the balance of the given account in tiny bars.
    /// - Parameters:
    ///   - account: The account to check the balance of.
    /// - Returns: `account`'s balance.
    public func getAccountBalance(account: AccountId) -> Result<UInt64, HederaError> {
        AccountBalanceQuery(client: self)
            .setAccount(account)
            .execute()
    }

    /// Gets the operator's account info.
    /// - Returns: The operator's account info.
    public func getAccountInfo() -> Result<AccountInfo, HederaError> {
        AccountInfoQuery(client: self)
            .setAccount(self.operator!.id)
            .execute()
    }

    /// Gets the given account's account info.
    /// - Parameters:
    ///   - account: The account to get the info of.
    /// - Returns: `account`'s account info.
    public func getAccountInfo(account: AccountId) -> Result<AccountInfo, HederaError> {
        AccountInfoQuery(client: self)
            .setAccount(account)
            .execute()
    }

    /// Gets the operator's Transaction Records.
    /// - Returns: The operator's Transaction Records.
    public func getAccountRecords() -> Result<[TransactionRecord], HederaError> {
        AccountRecordsQuery(client: self)
            .setAccount(self.operator!.id)
            .execute()
    }

    /// Gets the given account's transaction records.
    /// - Parameters:
    ///   - account: The account to get the transaction records for.
    /// - Returns: `account`'s transaction records.
    public func getAccountRecords(account: AccountId) -> Result<[TransactionRecord], HederaError> {
        AccountRecordsQuery(client: self)
            .setAccount(account)
            .execute()
    }

    private func channelFor(node: Node) -> Channel {
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
