import HederaCryptoSwift
import Foundation

public class Client {
    var `operator`: Operator?
    var network: Network
    var maxAttempts: UInt = 10
    var maxBackoff: TimeInterval = 8
    var minBackoff: TimeInterval = 0.25

    init(_ network: Network) {
        self.network = network
    }

    static func forNetwork(_ network: [String: AccountId]) -> Client {
        Client(Network.forNetwork(network))
    }

    func getOperatorAccountId() -> AccountId? {
        if let `operator` = `operator` {
            return `operator`.accountId
        } else {
            return nil
        }
    }

    func getOperatorPublicKey() -> PublicKey? {
        if let `operator` = `operator` {
            return `operator`.publicKey
        } else {
            return nil
        }
    }

    @discardableResult
    func setNetworkName(_ networkName: NetworkName) -> Self {
        network.setNetworkName(networkName)
        return self
    }

    func getNetworkName() -> NetworkName? {
        network.getNetworkName()
    }}

class Operator {
    var accountId: AccountId
    var transactionSigner: (_ data: [UInt8]) -> [UInt8]
    var publicKey: PublicKey

    init(_ accountId: AccountId, _ transactionSigner: @escaping (_ data: [UInt8]) -> [UInt8], publicKey: PublicKey) {
        self.accountId = accountId
        self.transactionSigner = transactionSigner
        self.publicKey = publicKey
    }
}