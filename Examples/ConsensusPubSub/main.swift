// SPDX-License-Identifier: Apache-2.0

import Hedera
import SwiftDotenv

@main
internal enum Program {
    internal static func main() async throws {
        let env = try Dotenv.load()
        let client = try Client.forName(env.networkName)

        client.setOperator(env.operatorAccountId, env.operatorKey)

        let topicId = try await TopicCreateTransaction()
            .topicMemo("sdk::swift::ConsensusPubSub")
            .execute(client)
            .getReceipt(client)
            .topicId!

        print("Created Topic `\(topicId)`")

        print("Waiting 10s for the mirror node to catch up")

        try await Task.sleep(nanoseconds: 1_000_000_000 * 10)

        _ = Task {
            print("Sending messages indefinitely")

            for i in 0... {
                let message = "Hello HCS: \(i)"

                print("publishing message \(i): `\(message)`")

                _ = try await TopicMessageSubmitTransaction()
                    .topicId(topicId)
                    .message(message.data(using: .utf8)!)
                    .execute(client)
                    .getReceipt(client)

                try await Task.sleep(nanoseconds: 1_000_000 * 1500)
            }

            print("Finished sending the message, press ctrl+c to exit once it's recieved")
        }

        let stream = TopicMessageQuery()
            .topicId(topicId)
            .subscribe(client)

        // note: There's only going to be a single message recieved.
        for try await message in stream {
            print(
                "(seq: `\(message.sequenceNumber)`, contents: `\(String(data: message.contents, encoding: .utf8)!)` reached consensus at \(message.consensusTimestamp)"
            )
        }
    }
}

extension Environment {
    /// Account ID for the operator to use in this example.
    internal var operatorAccountId: AccountId {
        AccountId(self["OPERATOR_ID"]!.stringValue)!
    }

    /// Private key for the operator to use in this example.
    internal var operatorKey: PrivateKey {
        PrivateKey(self["OPERATOR_KEY"]!.stringValue)!
    }

    /// The name of the hedera network this example should be ran against.
    ///
    /// Testnet by default.
    internal var networkName: String {
        self["HEDERA_NETWORK"]?.stringValue ?? "testnet"
    }
}
