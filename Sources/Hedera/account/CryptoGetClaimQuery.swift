import Foundation
import Sodium

public class CryptoGetClaimQuery: QueryBuilder<Claim> {
    public override init(client: Client) {
        super.init(client: client)

        body.cryptoGetClaim = Proto_CryptoGetClaimQuery()
    }

    @discardableResult
    public func setAccount(_ id: AccountId) -> Self {
        body.cryptoGetClaim.accountID = id.toProto()
        return self
    }

    @discardableResult
    public func setHash(_ hash: Bytes) -> Self {
        body.cryptoGetClaim.hash = Data(hash)
        return self
    }

    override func mapResponse(_ response: Proto_Response) throws -> Claim {
        guard case .cryptoGetClaim(let response) = response.response else {
            throw HederaError(message: "Query response was not of `cryptoGetClaim`")
        }

        return Claim(response.claim)
    }
}
