import SwiftProtobuf
import Sodium

// TODO: this should probably be its own file, and possibly an enum instead
struct HederaError: Error {}

public struct Transaction {
    let inner: Proto_Transaction

    init(_ tx: Proto_Transaction) {
        inner = tx
    }

    var bytes: Bytes {
        Bytes(inner.bodyBytes)
    }

    public func sign(with key: Ed25519PrivateKey) throws -> Self {
        let pubKey = key.publicKey.bytes
        let sigMap = inner.sigMap

        if sigMap.sigPair.contains(where: { (sig) in 
            let pubKeyPrefix = sig.pubKeyPrefix
            return pubKey.starts(with: pubKeyPrefix)
        }) {
            throw HederaError()
        }

        // TODO: write the rest of the function
        // TODO: private key needs to hold onto keypair from sodium

        return self
    }
}

extension Transaction: ProtoConvertible {
    func toProto() -> Proto_Transaction {
        inner
    }
}

// TODO: Add #sign -> Self
// TODO: Add #execute -> TransactionId
