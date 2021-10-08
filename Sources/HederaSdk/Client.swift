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

  let eventLoopGroup: EventLoopGroup

  init() {
    eventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: 1)
    network = Network(eventLoopGroup)
    mirrorNetwork = MirrorNetwork(eventLoopGroup)
  }

  deinit {
    try! eventLoopGroup.syncShutdownGracefully()
  }

  public static func forNetwork(_ network: [String: AccountId]) -> EventLoopFuture<Client> {
    let client = Client()
    return client.setNetwork(Network.forNetwork(client.eventLoopGroup, network))
  }

  public static func forMainnet() -> EventLoopFuture<Client> {
    let client = Client()
    return client.setNetwork(Network.forMainnet(client.eventLoopGroup))
  }

  public static func forTestnet() -> EventLoopFuture<Client> {
    let client = Client()
    return client.setNetwork(Network.forTestnet(client.eventLoopGroup))
  }

  public static func forPreviewnet() -> EventLoopFuture<Client> {
    let client = Client()
    return client.setNetwork(Network.forPreviewnet(client.eventLoopGroup))
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

  @discardableResult
  public func setOperator(_ accountId: AccountId, _ privateKey: PrivateKey) -> Self {
    `operator` = Operator(accountId, privateKey)
    return self
  }

  public func getOperatorAccountId() -> AccountId? {
    if let `operator` = `operator` {
      return `operator`.accountId
    } else {
      return nil
    }
  }

  public func getOperatorPublicKey() -> PublicKey? {
    if let `operator` = `operator` {
      return `operator`.publicKey
    } else {
      return nil
    }
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

  public func setMirrorNetwork(_ network: [String]) -> EventLoopFuture<Client> {
    mirrorNetwork.setNetwork(network).map { _ in self }
  }

  public func getMirrorNetwork() -> [String]? {
    mirrorNetwork.getNetwork()
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
