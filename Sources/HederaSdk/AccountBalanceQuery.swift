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

  override func executeAsync(_ node: Node) -> UnaryCall<Proto_Query, Proto_Response> {
    node.getCrypto().cryptoGetBalance(makeRequest(), callOptions: nil)
  }

  override func makeRequest() -> Proto_Query {
    var proto = Proto_Query()

    if let accountId = accountId {
      proto.cryptogetAccountBalance.accountID = accountId.toProtobuf()
    }

    return proto
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.cryptogetAccountBalance.header
  }

  override func mapResponse(_ response: Proto_Response) -> AccountBalance {
    AccountBalance(response.cryptogetAccountBalance)!
  }
}

extension AccountBalanceQuery: FromResponse {
  func mapResponse(_ response: Proto_Response) -> AccountBalance? {
    guard case .cryptogetAccountBalance(let response) = response.response else {
      fatalError("unreachable: response is not cryptogetAccountBalance")
    }

    return AccountBalance(response)
  }
}
