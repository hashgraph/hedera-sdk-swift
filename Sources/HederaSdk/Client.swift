import HederaCrypto
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

    public static func forNetwork(_ network: [String: AccountId]) -> Client {
        Client(Network.forNetwork(network))
    }

    @discardableResult
    public func setOperator(_ accountId: AccountId, _ privateKey: PrivateKey) -> Self {
        `operator` = Operator(accountId, privateKey)
        return self
    }

    public func getOperatorAccountId() -> AccountId? {
        if let `operator` = `operator` {
            return `operator`.accountId
        } else {
            return nil
        }
    }

    public func getOperatorPublicKey() -> PublicKey? {
        if let `operator` = `operator` {
            return `operator`.publicKey
        } else {
            return nil
        }
    }

    @discardableResult
    public func setNetworkName(_ networkName: NetworkName) -> Self {
        network.setNetworkName(networkName)
        return self
    }

    public func getNetworkName() -> NetworkName? {
        network.getNetworkName()
    }
}

class Operator {
    var accountId: AccountId
    var transactionSigner: (_ data: [UInt8]) -> [UInt8]
    var publicKey: PublicKey

    init(_ accountId: AccountId, _ transactionSigner: @escaping (_ data: [UInt8]) -> [UInt8], _ publicKey: PublicKey) {
        self.accountId = accountId
        self.transactionSigner = transactionSigner
        self.publicKey = publicKey
    }

    convenience init(_ accountId: AccountId, _ privateKey: PrivateKey) {
        self.init(accountId, privateKey.sign, privateKey.publicKey)
    }
}