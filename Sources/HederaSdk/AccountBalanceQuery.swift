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

  override func isPaymentRequired() -> Bool {
    false
  }

  override func executeAsync(_ index: Int, save: Bool? = true) -> UnaryCall<
    Proto_Query, Proto_Response
  > {
    nodes[circular: index].getCrypto().cryptoGetBalance(
      makeRequest(index, save: save), callOptions: nil)
  }

  override func makeRequest(_ index: Int, save: Bool? = true) -> Proto_Query {
    if let query = requests[index] {
      return query
    }

    var proto = Proto_Query()

    // TODO: What happens if we don't d this
    proto.cryptogetAccountBalance = Proto_CryptoGetAccountBalanceQuery()

    if let accountId = accountId {
      proto.cryptogetAccountBalance.accountID = accountId.toProtobuf()
    }

    if save ?? false {
      requests[index] = proto
    }

    return proto
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.cryptogetAccountBalance.header
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> AccountBalance {
    AccountBalance(response.cryptogetAccountBalance)!
  }
}
