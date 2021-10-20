import Foundation
import GRPC
import HederaCrypto
import NIO

public class Client {
  var `operator`: Operator?
  var network: Network
  var mirrorNetwork: MirrorNetwork
  var maxAttempts: UInt = 10
  var maxBackoff: TimeInterval = 8
  var minBackoff: TimeInterval = 0.25
  var defaultMaxTransactionFee: Hbar?

  let eventLoopGroup: EventLoopGroup

  init() {
    eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    network = Network(eventLoopGroup)
    mirrorNetwork = MirrorNetwork(eventLoopGroup)
  }

  deinit {
    try! eventLoopGroup.syncShutdownGracefully()
  }

  public class func forNetwork(_ network: [String: AccountId]) -> EventLoopFuture<Client> {
    let client = Client()
    return client.setNetwork(Network.forNetwork(client.eventLoopGroup, network))
  }

  public class func forMainnet() -> EventLoopFuture<Client> {
    let client = Client()
    return client.setNetwork(Network.forMainnet(client.eventLoopGroup)).flatMap {
      $0.setMirrorNetwork(MirrorNetwork.forMainnet($0.eventLoopGroup))
    }
  }

  public class func forTestnet() -> EventLoopFuture<Client> {
    let client = Client()
    return client.setNetwork(Network.forTestnet(client.eventLoopGroup)).flatMap {
      $0.setMirrorNetwork(MirrorNetwork.forTestnet($0.eventLoopGroup))
    }
  }

  public class func forPreviewnet() -> EventLoopFuture<Client> {
    let client = Client()
    return client.setNetwork(Network.forPreviewnet(client.eventLoopGroup)).flatMap {
      $0.setMirrorNetwork(MirrorNetwork.forPreviewnet($0.eventLoopGroup))
    }
  }

  func setNetwork(_ network: EventLoopFuture<Network>) -> EventLoopFuture<Client> {
    network.map { network in
      self.network = network
      return self
    }
  }

  public func setNetwork(_ network: [String: AccountId]) -> EventLoopFuture<Client> {
    self.network.setNetwork(network).map { _ in self }
  }

  func setMirrorNetwork(_ mirrorNetwork: EventLoopFuture<MirrorNetwork>) -> EventLoopFuture<Client>
  {
    mirrorNetwork.map { mirrorNetwork in
      self.mirrorNetwork = mirrorNetwork
      return self
    }
  }

  public func setMirrorNetwork(_ mirrorNetwork: [String]) -> EventLoopFuture<Client> {
    self.mirrorNetwork.setNetwork(mirrorNetwork).map { _ in self }
  }

  @discardableResult
  public func setOperator(_ accountId: AccountId, _ privateKey: PrivateKey) -> Self {
    `operator` = Operator(accountId, privateKey)
    return self
  }

  public func getOperatorAccountId() -> AccountId? {
    `operator`?.accountId
  }

  public func getOperatorPublicKey() -> PublicKey? {
    `operator`?.publicKey
  }

  @discardableResult
  public func setNetworkName(_ networkName: NetworkName) -> Self {
    network.setNetworkName(networkName)
    return self
  }

  public func getNetworkName() -> NetworkName? {
    network.getNetworkName()
  }

  public func getNetwork() -> [String: AccountId]? {
    network.getNetwork()
  }

  public func getMirrorNetwork() -> [String]? {
    mirrorNetwork.getNetwork()
  }

  public func getDefaultMaxTransactionFee() -> Hbar? {
    defaultMaxTransactionFee
  }

  public func setDefaultMaxTransactionFee(_ defaultMaxTransactionFee: Hbar) -> Self {
    self.defaultMaxTransactionFee = defaultMaxTransactionFee
    return self
  }
}

class Operator {
  var accountId: AccountId
  var transactionSigner: (_ data: [UInt8]) -> [UInt8]
  var publicKey: PublicKey

  init(
    _ accountId: AccountId, _ transactionSigner: @escaping (_ data: [UInt8]) -> [UInt8],
    _ publicKey: PublicKey
  ) {
    self.accountId = accountId
    self.transactionSigner = transactionSigner
    self.publicKey = publicKey
  }

  convenience init(_ accountId: AccountId, _ privateKey: PrivateKey) {
    self.init(accountId, privateKey.sign, privateKey.publicKey)
  }
}
