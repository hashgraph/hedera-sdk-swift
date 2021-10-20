import GRPC
import HederaProtoServices
import NIO

public final class AccountStakersQuery: Query<[Transfer]> {
  var accountId: AccountId? = nil

  @discardableResult
  public func setAccountId(_ accountId: AccountId) -> Self {
    self.accountId = accountId
    return self
  }

  public func getAccountId() -> AccountId? {
    accountId
  }

  convenience init(_ proto: Proto_Query) {
    self.init()

    setAccountId(AccountId(proto.cryptoGetProxyStakers.accountID))
  }

  override func isPaymentRequired() -> Bool {
    true
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Query, CallOptions?) ->
    UnaryCall<Proto_Query, Proto_Response>
  {
    nodes[circular: index].getCrypto().getStakersByAccountID
  }

  override func onMakeRequest(_ proto: inout Proto_Query) {
    // TODO: What happens if we don't d this
    proto.cryptoGetProxyStakers = Proto_CryptoGetStakersQuery()

    if let accountId = accountId {
      proto.cryptoGetProxyStakers.accountID = accountId.toProtobuf()
    }
  }

  // TODO: Why does this need to exit here?
  override func mapStatusError(_ response: Proto_Response) -> Error {
    PrecheckStatusError(
      status: response.cryptoGetProxyStakers.header.nodeTransactionPrecheckCode,
      transactionId: transactionIds.first!)
  }

  override func onFreeze(_ query: inout Proto_Query, _ header: Proto_QueryHeader) {
    query.cryptoGetProxyStakers.header = header
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.cryptoGetProxyStakers.header
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> [Transfer] {
    let stakers = response.cryptoGetProxyStakers
    return stakers.hasStakers ? stakers.stakers.proxyStaker.map { Transfer($0)! } : [Transfer]()
  }
}
