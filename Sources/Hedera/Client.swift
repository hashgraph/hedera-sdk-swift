import Sodium
import GRPC
import NIO

struct Node {
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

let defaultMaxTransactionFee: UInt64 = 100_000_000 // 1h

let defaultMaxQueryPayment: UInt64 = 100_000_000 // 1h

public class Client {
    var `operator`: Operator?

    var network: [AccountId: Node]

    var grpcClients: [AccountId: HederaGRPCClient] = [:]

    /// The default maximum fee for a transaction.
    /// This can be overridden on an individual transaction with `setMaxTransactionFee()`.
    var maxTransactionFee = defaultMaxTransactionFee

    /// The maximum payment that can be automatically attached to a query.
    /// If this is not set, payments will not be made automatically for queries.
    /// This can be overridden for an individual query with `.setPayment()`.
    var maxQueryPayment: UInt64 = defaultMaxQueryPayment

    /// Eventloop that will be shared by all grpc clients
    let eventLoopGroup: EventLoopGroup
    let shouldCloseEventLoopOnDestroy: Bool

    public convenience init(network: [String: AccountId], eventLoopGroup: EventLoopGroup) {
        self.init(network: network, eventLoopGroup: eventLoopGroup, shouldCloseEventLoopOnDestroy: false)
    }

    public convenience init(network: [String: AccountId]) {
        self.init(network: network,
            eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1),
            shouldCloseEventLoopOnDestroy: true)
    }

    init(network: [String: AccountId], eventLoopGroup: EventLoopGroup, shouldCloseEventLoopOnDestroy: Bool) {
        self.network = Dictionary(uniqueKeysWithValues: network.map { (key, value) in
            return (value, Node(accountId: value, address: key))
        })
        self.eventLoopGroup = eventLoopGroup
        self.shouldCloseEventLoopOnDestroy = shouldCloseEventLoopOnDestroy
    }

    deinit {
        if shouldCloseEventLoopOnDestroy {
            try! eventLoopGroup.syncShutdownGracefully()
        }
    }

    /// Sets the account that will be paying for transactions and queries on the network.
    /// - Returns: Self for fluent usage.
    @discardableResult
    public func setOperator(id: AccountId, privateKey: Ed25519PrivateKey) -> Self {
        return setOperator(Operator(id: id, privateKey: privateKey))
    }

    /// Sets the account that will be paying for transactions and queries on the network.
    /// - Returns: Self for fluent usage.
    @discardableResult
    public func setOperator(id: AccountId, signer: @escaping Signer, publicKey: Ed25519PublicKey) -> Self {
        return setOperator(Operator(id: id, signer: signer, publicKey: publicKey))
    }

    @discardableResult
    func setOperator(_ operator: Operator) -> Self {
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

    func pickNode() -> Node {
        network.randomElement()!.value
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
