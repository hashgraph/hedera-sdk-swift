import GRPC
import HederaProtoServices
import NIO

class Node: ManagedNode<AccountId> {
  var accountId: AccountId
  var crypto: Proto_CryptoServiceClient?

  init(_ address: ManagedNodeAddress, _ accountId: AccountId) {
    self.accountId = accountId
    super.init(address)
  }

  convenience init?(_ address: String, _ accountId: AccountId) {
    if let managedNodeAddress = ManagedNodeAddress(address) {
      self.init(managedNodeAddress, accountId)
      return
    }

    return nil
  }

  override func getKey() -> AccountId {
    accountId
  }

  func getCrypto() -> Proto_CryptoServiceClient {
    if let crypto = crypto {
      return crypto
    }

    crypto = Proto_CryptoServiceClient(channel: getConnection())
    return crypto!
  }
}
