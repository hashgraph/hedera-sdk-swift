import Sodium

public struct Operator {
    let id: AccountId
    let signer: (Bytes) -> Bytes
    let publicKey: Ed25519PublicKey
    
    /// - Parameters:
    ///   - id: Account ID
    ///   - signer: closure that will be called to sign transactions. Useful for requesting signing from a hardware wallet that won't give you the private key.
    ///   - publicKey: public key associated with the signer
    ///   - message: the serialized transaction that will be signed
    public init(id: AccountId, signer: @escaping (_ message: Bytes) -> Bytes, publicKey: Ed25519PublicKey) {
        self.id = id
        self.signer = signer
        self.publicKey = publicKey
    }

    /// - Parameters:
    ///   - id: Account ID
    ///   - privateKey: private key that will be used to sign transactions.
    public init(id: AccountId, privateKey: Ed25519PrivateKey) {
        self.init(id: id, signer: privateKey.sign, publicKey: privateKey.publicKey)
    }
}
