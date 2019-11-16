import Sodium
import GRPC
import NIO

public struct Node {
    let accountId: AccountId
    let address: String
    
    var host: String {
        let colonIndex = address.firstIndex(of: ":")!
        return String(address.prefix(upTo: colonIndex))
    }
    
    var port: Int {
        let colonIndex = address.firstIndex(of: ":")!
        return Int(String(address.suffix(from: address.index(after: colonIndex))))!
    }
}
    
typealias HederaGRPCClient = (fileService: Proto_FileServiceServiceClient,
    cryptoService: Proto_CryptoServiceServiceClient,
    contractService: Proto_SmartContractServiceServiceClient)

let defaultMaxTransactionFee: UInt64 = 100_000_000

public class Client {
    var `operator`: Operator?

    var nodes: [AccountId: Node]
    var node: Node?

    var grpcClients: [AccountId: HederaGRPCClient] = [:]

    /// The default maximum fee for a transaction.
    /// This can be overridden on an individual transaction with `setMaxTransactionFee()`.
    var maxTransactionFee = defaultMaxTransactionFee

    /// The maximum payment that can be automatically attached to a query.
    /// If this is not set, payments will not be made automatically for queries.
    /// This can be overridden for an individual query with `.setPayment()`.
    var maxQueryPayment: UInt64?

    /// Eventloop that will be shared by all grpc clients
    let eventLoopGroup: EventLoopGroup

    public init(node id: AccountId, address url: String, eventLoopGroup: EventLoopGroup) {
        nodes = [ id: Node(accountId: id, address: url) ]
        self.eventLoopGroup = eventLoopGroup
    }

    public init(nodes: [(AccountId, String)], eventLoopGroup: EventLoopGroup) {
        let keys = nodes.map { $0.0 }
        let values = nodes.map { Node(accountId: $0.0, address: $0.1) }
        self.nodes = Dictionary(uniqueKeysWithValues: zip(keys, values))
        self.eventLoopGroup = eventLoopGroup
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

    public func pickNode() -> Node {
        nodes.randomElement()!.value
    }

    /// Gets the balance of the operator's account in tiny bars.
    /// - Returns: The operator's account balance.
    public func getAccountBalance() -> Result<UInt64, HederaError> {
        getAccountBalance(account: self.operator!.id)
    }

    /// Gets the balance of the given account in tiny bars.
    /// - Parameters:
    ///   - account: The account to check the balance of.
    /// - Returns: `account`'s balance.
    public func getAccountBalance(account: AccountId) -> Result<UInt64, HederaError> {
        AccountBalanceQuery(node: node ?? pickNode())
            .setAccount(account)
            .execute(client: self)
    }

    /// Gets the operator's account info.
    /// - Returns: The operator's account info.
    public func getAccountInfo() -> Result<AccountInfo, HederaError> {
        getAccountInfo(account: self.operator!.id)
    }

    /// Gets the given account's account info.
    /// - Parameters:
    ///   - account: The account to get the info of.
    /// - Returns: `account`'s account info.
    public func getAccountInfo(account: AccountId) -> Result<AccountInfo, HederaError> {
        AccountInfoQuery(node: node ?? pickNode())
            .setAccount(account)
            .execute(client: self)
    }

    /// Gets the operator's Transaction Records.
    /// - Returns: The operator's Transaction Records.
    public func getAccountRecords() -> Result<[TransactionRecord], HederaError> {
        getAccountRecords(account: self.operator!.id)
    }

    /// Gets the given account's transaction records.
    /// - Parameters:
    ///   - account: The account to get the transaction records for.
    /// - Returns: `account`'s transaction records.
    public func getAccountRecords(account: AccountId) -> Result<[TransactionRecord], HederaError> {
        AccountRecordsQuery(node: node ?? pickNode())
            .setAccount(account)
            .execute(client: self)
    }

    func grpcClient(for node: Node) -> HederaGRPCClient {
        if let service = grpcClients[node.accountId] {
            return service
        } else {
            let configuration = ClientConnection.Configuration(
                target: .hostAndPort(node.host, node.port),
                eventLoopGroup: eventLoopGroup)
            let connection = ClientConnection(configuration: configuration)
            let fileService = Proto_FileServiceServiceClient(connection: connection)
            let cryptoService = Proto_CryptoServiceServiceClient(connection: connection)
            let contractService = Proto_SmartContractServiceServiceClient(connection: connection)
            let service = HederaGRPCClient(
                fileService: fileService,
                cryptoService: cryptoService,
                contractService: contractService)
            
            grpcClients[node.accountId] = service
            return grpcClients[node.accountId]!
        }
    }
}
