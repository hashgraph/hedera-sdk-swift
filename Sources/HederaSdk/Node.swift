import GRPC
import HederaProtoServices
import NIO

public class Node {
    var accountId: AccountId
    var address: NodeAddress
    var connection: ClientConnection?
    var crypto: Proto_CryptoServiceClient?


    init(_ address: String, _ accountId: AccountId) {
        self.accountId = accountId
        self.address = NodeAddress(address)
    }

    func getConnection() -> ClientConnection {
        if let connection = connection {
            return connection
        }

        let configuration = ClientConnection.Configuration.default(
                target: .hostAndPort(address.address, Int(address.port ?? 0)),
                eventLoopGroup: PlatformSupport.makeEventLoopGroup(loopCount: 1)
        )
        connection = ClientConnection(configuration: configuration)
        return connection!
    }

    func getCrypto() -> Proto_CryptoServiceClient {
        if let crypto = crypto {
            return crypto
        }

        crypto = Proto_CryptoServiceClient(channel: getConnection())
        return crypto!
    }

    func close() -> EventLoopFuture<Void>? {
        connection?.close()
    }
}
