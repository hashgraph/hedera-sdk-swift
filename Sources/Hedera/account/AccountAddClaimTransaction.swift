public final class AccountAddClaimTransaction: TransactionBuilder {
    
    public override init(client: Client) {
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
    
//    override static func executeClosure(_ grpc: HederaGRPCClient, _ tx: Proto_Transaction) throws -> Proto_TransactionResponse {
//        try grpc.cryptoService.addClaim(tx)
//    }
}
