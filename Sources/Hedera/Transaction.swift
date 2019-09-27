import SwiftProtobuf
import Sodium
import Foundation

// TODO: this should probably be its own file, and possibly an enum instead
struct HederaError: Error {}

public struct Transaction {
    var inner: Proto_Transaction

    init(_ tx: Proto_Transaction) {
        inner = tx
    }

    var bytes: Bytes {
        Bytes(inner.bodyBytes)
    }

    // TODO: definitely test this function to make sure this works as it should
    public mutating func sign(with key: Ed25519PrivateKey) throws -> Self {
        if !inner.hasSigMap { inner.sigMap = Proto_SignatureMap() }
        
        let pubKey = key.publicKey.bytes

        if inner.sigMap.sigPair.contains(where: { (sig) in 
            let pubKeyPrefix = sig.pubKeyPrefix
            return pubKey.starts(with: pubKeyPrefix)
        }) {
            // Transaction was already signed with this key!
            throw HederaError()
        }

        let sig = key.sign(message: Bytes(inner.bodyBytes))
        var sigPair = Proto_SignaturePair()
        sigPair.pubKeyPrefix = Data(pubKey)
        sigPair.ed25519 = Data(sig)

        inner.sigMap.sigPair.append(sigPair)

        return self
    }
}

extension Transaction: ProtoConvertible {
    func toProto() -> Proto_Transaction {
        inner
    }
}

// TODO: Add #execute -> TransactionId
