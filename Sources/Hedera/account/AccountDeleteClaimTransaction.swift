import Sodium
import Foundation

public final class AccountDeleteClaimTransaction: TransactionBuilder {
    public override init(client: Client? = nil) {
        super.init(client: client)

        body.cryptoDeleteClaim = Proto_CryptoDeleteClaimTransactionBody()
    }

    @discardableResult
    public func setAccount(_ id: AccountId) -> Self {
        body.cryptoDeleteClaim.accountIdtoDeleteFrom = id.toProto()

        return self
    }

    @discardableResult
    public func setHash(_ hash: Bytes) -> Self {
        body.cryptoDeleteClaim.hashToDelete = Data(hash)

        return self
    }
}
