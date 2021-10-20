import GRPC
import HederaProtoServices
import NIO

public final class AccountRecordsQuery: Query<[TransactionRecord]> {
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

    setAccountId(AccountId(proto.cryptoGetAccountRecords.accountID))
  }

  override func isPaymentRequired() -> Bool {
    true
  }

  override func getMethodDescriptor(_ index: Int) -> (_ request: Proto_Query, CallOptions?) ->
    UnaryCall<Proto_Query, Proto_Response>
  {
    nodes[circular: index].getCrypto().getAccountRecords
  }

  override func onMakeRequest(_ proto: inout Proto_Query) {
    // TODO: What happens if we don't d this
    proto.cryptoGetAccountRecords = Proto_CryptoGetAccountRecordsQuery()

    if let accountId = accountId {
      proto.cryptoGetAccountRecords.accountID = accountId.toProtobuf()
    }
  }

  // TODO: Why does this need to exit here?
  override func mapStatusError(_ response: Proto_Response) -> Error {
    PrecheckStatusError(
      status: response.cryptoGetAccountRecords.header.nodeTransactionPrecheckCode,
      transactionId: transactionIds.first!)
  }

  override func onFreeze(_ query: inout Proto_Query, _ header: Proto_QueryHeader) {
    query.cryptoGetAccountRecords.header = header
  }

  override func mapResponseHeader(_ response: Proto_Response) -> Proto_ResponseHeader {
    response.cryptoGetAccountRecords.header
  }

  override func mapResponse(_ index: Int, _ response: Proto_Response) -> [TransactionRecord] {
    response.cryptoGetAccountRecords.records.map { TransactionRecord($0)! }
  }
}
