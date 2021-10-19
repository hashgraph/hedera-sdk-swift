import Foundation
import GRPC
import HederaProtoServices
import NIO

public final class AccountInfoQuery: Query<AccountInfo> {
  var accountId: AccountId? = nil

  @discardableResult
  public func setAccountId(_ accountId: AccountId) -> Self {
    self.accountId = accountId
    return self
  }

  convenience init(_ proto: Proto_Query) {
    self.init()

    setAccountId(AccountId(proto.cryptoGetInfo.accountID))
  }

  override func executeAsync(_ index: Int, save: Bool? = true) -> UnaryCall<
    Proto_Query, Proto_Response
  > {
    nodes[circular: index].getCrypto().getAccountInfo(try! makeRequest(index, save: save))
  }

  override func onMakeRequest(_ proto: inout Proto_Query) {
    // TODO: What happens if we don't do this
    proto.cryptoGetInfo = Proto_CryptoGetInfoQuery()

    if let accountId = accountId {
      proto.cryptoGetInfo.accountID = accountId.toProtobuf()
    }
  }

  override func onFreeze(_ query: inout Proto_Query, _ header: Proto_QueryHeader) {
    query.cryptoGetInfo.header = header
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.cryptoGetInfo.header
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> AccountInfo {
    AccountInfo(response.cryptoGetInfo.accountInfo)!
  }
}
