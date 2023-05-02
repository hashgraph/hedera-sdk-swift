import Foundation

internal enum Signer: Sendable {
    case privateKey(PrivateKey)
    case arbitrary(PublicKey, @Sendable (Data) -> Data)

    internal func callAsFunction(_ message: Data) -> (PublicKey, Data) {
        switch self {
        case .privateKey(let key): return (publicKey, key.sign(message))
        case .arbitrary(let key, let signFunc): return (key, signFunc(message))
        }
    }

    internal var publicKey: PublicKey {
        switch self {
        case .privateKey(let key): return key.publicKey
        case .arbitrary(let publicKey, _): return publicKey
        }
    }
}
