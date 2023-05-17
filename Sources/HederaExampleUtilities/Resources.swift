import Foundation

private struct ContractJson: Decodable {
    private let object: String?
    private let bytecode: String?

    fileprivate var bytecodeHex: String {
        (object ?? bytecode)!
    }
}

public enum Resources {
    private static func bytecode(forUrl url: URL) async throws -> String {
        try await JSONDecoder().decode(ContractJson.self, from: URLSession.shared.data(from: url).0).bytecodeHex
    }

    /// The "big contents" used in `ConsensusPubSubChunked` and `FileAppendChunked`.
    public static var bigContents: String {
        get async throws {
            // this is indeed, the way this is expected to be done :/
            let url = Bundle.module.url(forResource: "big-contents", withExtension: "txt")!
            return try await String(data: URLSession.shared.data(from: url).0, encoding: .utf8)!
        }
    }

    /// Bytecode for the simple contract example.
    public static var simpleContract: String {
        get async throws {
            let url = Bundle.module.url(forResource: "hello-world", withExtension: "json")!

            return try await bytecode(forUrl: url)
        }
    }

    /// Bytecode for the stateful contract example.
    public static var statefulContract: String {
        get async throws {
            let url = Bundle.module.url(forResource: "stateful", withExtension: "json")!

            return try await bytecode(forUrl: url)
        }
    }
}
