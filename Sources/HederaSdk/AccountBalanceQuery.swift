import GRPC
import HederaProtoServices
import NIO

public final class AccountBalanceQuery: Query<AccountBalance> {
  var accountId: AccountId? = nil

  @discardableResult
  public func setAccountId(_ accountId: AccountId) -> Self {
    self.accountId = accountId
    return self
  }

  convenience init(_ proto: Proto_Query) {
    self.init()

    setAccountId(AccountId(proto.cryptogetAccountBalance.accountID))
  }

  override func isTransactionIdRequired() -> Bool {
    false
  }

  override func isPaymentRequired() -> Bool {
    false
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Query, CallOptions?) ->
    UnaryCall<Proto_Query, Proto_Response>
  {
    nodes[circular: index].getCrypto().cryptoGetBalance
  }

  override func onMakeRequest(_ proto: inout Proto_Query) {
    // TODO: What happens if we don't d this
    proto.cryptogetAccountBalance = Proto_CryptoGetAccountBalanceQuery()

    if let accountId = accountId {
      proto.cryptogetAccountBalance.accountID = accountId.toProtobuf()
    }
  }

  override func onFreeze(_ query: inout Proto_Query, _ header: Proto_QueryHeader) {
    query.cryptogetAccountBalance.header = header
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.cryptogetAccountBalance.header
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> AccountBalance {
    AccountBalance(response.cryptogetAccountBalance)!
  }
}
