import GRPC
import HederaProtoServices
import NIO

class Node: ManagedNode {
  var accountId: AccountId
  var crypto: Proto_CryptoServiceClient?

  init(_ address: ManagedNodeAddress, _ accountId: AccountId) {
    self.accountId = accountId
    super.init(address)
  }

  convenience init?(_ address: String, _ accountId: AccountId) {
    guard let managedNodeAddress = ManagedNodeAddress(address) else {
      return nil
    }

    self.init(managedNodeAddress, accountId)
  }

  func getConnection() -> ClientConnection {
    if let connection = connection {
      return connection
    }

    let configuration = ClientConnection.Configuration.default(
      target: .hostAndPort(address.address, Int(address.port)),
      eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
    )
    connection = ClientConnection(configuration: configuration)
    return connection!
  }

  func getCrypto() -> Proto_CryptoServiceClient {
    if let crypto = crypto {
      return crypto
    }

    crypto = Proto_CryptoServiceClient(channel: getConnection())
    return crypto!
  }

  func close() -> EventLoopFuture<Void>? {
    connection?.close()
  }
}
