public final class CryptoTransferTransaction: TransactionBuilder {
    public override init() {
        super.init()

        var inner = Proto_CryptoTransferTransactionBody()
        inner.transfers = Proto_TransferList()

        body.cryptoTransfer = inner
    }

    @discardableResult
    public func addSender(_ sender: AccountId, amount: UInt64) -> Self {
        addTransfer(account: sender, amount: -Int64(amount))
    }

    @discardableResult
    public func addRecipient(_ recipient: AccountId, amount: UInt64) -> Self {
        addTransfer(account: recipient, amount: Int64(amount))
    }

    @discardableResult
    public func addTransfer(account: AccountId, amount: Int64) -> Self {
        var accountAmount = Proto_AccountAmount()
        accountAmount.accountID = account.toProto()
        accountAmount.amount = amount

        body.cryptoTransfer.transfers.accountAmounts.append(accountAmount)

        return self
    }
}
