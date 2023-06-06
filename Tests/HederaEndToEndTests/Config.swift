import Hedera
import SwiftDotenv
import XCTest

internal struct TestEnvironment {
    internal struct Config {
        private static func envBool(env: Environment?, key: String, defaultValue: Bool) -> Bool {
            guard let value = env?[key]?.stringValue else {
                return defaultValue
            }

            switch value {
            case "1":
                return true
            case "0":
                return false
            case _:
                print(
                    "warn: expected `\(key)` to be `1` or `0` but it was `\(value)`, returning `\(defaultValue)`",
                    stderr)

                return defaultValue
            }
        }

        init() {
            let env = try? Dotenv.load()

            network = env?[Keys.network]?.stringValue ?? "testnet"

            let runNonfree = Self.envBool(env: env, key: Keys.runNonfree, defaultValue: false)

            `operator` = .init(env: env)

            if `operator` == nil && runNonfree {
                print("warn: forcing `runNonfree` to false because operator is nil", stderr)
                self.runNonfreeTests = false
            } else {
                self.runNonfreeTests = runNonfree
            }
        }

        internal let network: String
        internal let `operator`: TestEnvironment.Operator?
        internal let runNonfreeTests: Bool
    }

    internal struct Operator {
        init?(env: Environment?) {
            guard let env = env else {
                return nil
            }

            let operatorKeyStr = env[Keys.operatorKey]?.stringValue
            let operatorAccountIdStr = env[Keys.operatorAccountId]?.stringValue

            switch (operatorKeyStr, operatorAccountIdStr) {
            case (nil, nil):
                return nil

            case (.some, nil), (nil, .some):

                // warn:
                return nil

            case (.some(let key), .some(let accountId)):

                do {
                    let accountId = try AccountId.fromString(accountId)
                    let key = try PrivateKey.fromString(key)

                    self.accountId = accountId
                    self.privateKey = key
                } catch {
                    print("warn: forcing operator to nil because an error occurred: \(error)")
                    return nil
                }
            }
        }

        internal let accountId: AccountId
        internal let privateKey: PrivateKey
    }

    private enum Keys {
        fileprivate static let network = "TEST_NETWORK_NAME"
        fileprivate static let operatorKey = "TEST_OPERATOR_KEY"
        fileprivate static let operatorAccountId = "TEST_OPERATOR_ACCOUNT_ID"
        fileprivate static let runNonfree = "TEST_RUN_NONEFREE"
    }

    private init() {
        config = .init()

        // todo: warn when error
        client = (try? Client.forName(config.network)) ?? Client.forTestnet()

        if let op = config.operator {
            client.setOperator(op.accountId, op.privateKey)
        }
    }

    internal static let global: TestEnvironment = TestEnvironment()
    internal static var nonFree: NonfreeTestEnvironment {
        get throws {
            if let inner = NonfreeTestEnvironment.global {
                return inner
            }

            throw XCTSkip("Test requires non-free test environment, but the test environment only allows free tests")
        }
    }

    let client: Hedera.Client
    let config: Config
}

internal struct NonfreeTestEnvironment {
    internal struct Config {
        init?(base: TestEnvironment.Config) {

            if !base.runNonfreeTests {
                return nil
            }

            self.operator = base.`operator`!
            self.network = base.network
        }

        internal let network: String
        internal let `operator`: TestEnvironment.Operator
    }

    private init?(_ env: TestEnvironment) {
        guard let config = Config(base: env.config) else {
            return nil
        }

        self.config = config
        self.client = env.client
    }

    fileprivate static let global: Self? = Self(.global)

    internal let client: Hedera.Client
    internal let config: Config
}
