public final class CryptoTransferTransaction: TransactionBuilder {
    public override init() {
        super.init()

        var inner = Proto_CryptoTransferTransactionBody()
        inner.transfers = Proto_TransferList()

        body.cryptoTransfer = inner
    }

    @discardableResult
    public func addSender(_ sender: AccountId, amount: Hbar) -> Self {
        guard amount > Hbar.ZERO else { fatalError("amount must be nonnegative")}
        return addTransfer(account: sender, amount: Hbar.fromTinybar(amount: -amount.asTinybar()))
    }

    @discardableResult
    public func addRecipient(_ recipient: AccountId, amount: Hbar) -> Self {
        guard amount > Hbar.ZERO else { fatalError("amount must be nonnegative")}
        return addTransfer(account: recipient, amount: amount)
    }

    @discardableResult
    public func addTransfer(account: AccountId, amount: Hbar) -> Self {
        var accountAmount = Proto_AccountAmount()
        accountAmount.accountID = account.toProto()
        accountAmount.amount = amount.asTinybar()

        body.cryptoTransfer.transfers.accountAmounts.append(accountAmount)

        return self
    }
}
