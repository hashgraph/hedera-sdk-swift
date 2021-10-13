import HederaSdk
import HederaCrypto
import Foundation
import GRPC
import NIO

let client = try! Client.forTestnet().wait()

let info = try! AccountInfoQuery()
        .setAccountId(AccountId(3))
        .executeAsync(client)
        .wait()

print("balance = \(info)")