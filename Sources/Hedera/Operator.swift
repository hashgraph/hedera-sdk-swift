import Sodium

public typealias Signer = (_ message: Bytes) -> Bytes

public struct Operator {
    let id: AccountId
    let signer: Signer
    let publicKey: Ed25519PublicKey
    
    /// - Parameters:
    ///   - id: Account ID
    ///   - signer: closure that will be called to sign transactions. Useful for requesting signing from a hardware wallet that won't give you the private key.
    ///   - publicKey: public key associated with the signer
    public init(id: AccountId, signer: @escaping Signer, publicKey: Ed25519PublicKey) {
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
