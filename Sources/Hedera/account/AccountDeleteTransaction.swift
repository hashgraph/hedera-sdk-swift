import SwiftProtobuf

public final class AccountDeleteTransaction: TransactionBuilder {
    public override init() {
        super.init()

        body.cryptoDelete = Proto_CryptoDeleteTransactionBody()
    }

    /// Sets the account which will receive all remaining hbars
    @discardableResult
    public func setTransferAccount(_ id: AccountId) -> Self {
        body.cryptoDelete.transferAccountID = id.toProto()
        return self
    }

    /// Sets the account to be deleted
    @discardableResult
    public func setDeleteAccount(_ id: AccountId) -> Self {
        body.cryptoDelete.deleteAccountID = id.toProto()
        return self
    }
}
