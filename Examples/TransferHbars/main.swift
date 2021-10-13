import HederaSdk
import HederaCrypto
import Foundation
import GRPC
import NIO

let operatorId = ProcessInfo.processInfo.environment["OPERATOR_ID"]
let operatorKey = ProcessInfo.processInfo.environment["OPERATOR_KEY"]

if operatorId == nil || operatorKey == nil {
    fatalError("environment variables OPERATOR_KEY and OPERATOR_ID must be present")
}

let client = try! Client.forTestnet().wait()
        .setOperator(AccountId(operatorId!)!, PrivateKey(operatorKey!)!)

let response = try! TransferTransaction()
        .addHbarTransfer(AccountId(3), Hbar(1))
        .addHbarTransfer(client.getOperatorAccountId()!, Hbar(-1))
        .executeAsync(client)
        .wait()

print("response = \(response)")

let receipt = try! response.getReceiptAsync(client).wait()

print("receipt = \(receipt)")
