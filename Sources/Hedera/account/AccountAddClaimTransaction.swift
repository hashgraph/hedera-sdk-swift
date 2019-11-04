import Sodium
import Foundation

public final class AccountAddClaimTransaction: TransactionBuilder {
    public override init(client: Client? = nil) {
        super.init(client: client)
        body.cryptoAddClaim = Proto_CryptoAddClaimTransactionBody()
        body.cryptoAddClaim.claim = Proto_Claim()
        body.cryptoAddClaim.claim.keys = Proto_KeyList()
    }
    
    @discardableResult
    public func setAccount(_ id: AccountId) -> Self {
        body.cryptoAddClaim.claim.accountID = id.toProto()
        return self
    }
    
    @discardableResult
    public func addKey<T: PublicKey>(_ key: T) -> Self {
        body.cryptoAddClaim.claim.keys.keys.append(key.toProto())
        return self
    }
    
    @discardableResult
    public func setHash(_ hash: Bytes) -> Self {
        body.cryptoAddClaim.claim.hash = Data(hash)
        
        return self
    }
    
    @discardableResult
    public func setHash(_ hash: Data) -> Self {
        body.cryptoAddClaim.claim.hash = hash
        
        return self
    }
}
