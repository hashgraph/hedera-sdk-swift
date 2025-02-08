// SPDX-License-Identifier: Apache-2.0

/// Struct to hold the parameters of a 'pauseToken' JSON-RPC method call.
internal struct PauseTokenParams {

    internal var tokenId: String? = nil
    internal var commonTransactionParams: CommonTransactionParams? = nil

    internal init(_ request: JSONRequest) throws {
        if let params = try getOptionalParams(request) {
            self.tokenId = try getOptionalJsonParameter("tokenId", params, JSONRPCMethod.pauseToken)
            self.commonTransactionParams = try CommonTransactionParams(
                try getOptionalJsonParameter("commonTransactionParams", params, JSONRPCMethod.pauseToken),
                JSONRPCMethod.pauseToken)
        }
    }
}
