public class AccountInfoQuery: QueryBuilder<AccountInfo> {
    public override init(client: Client) {
        super.init(client: client)

        body.cryptoGetInfo = Proto_CryptoGetInfoQuery()
    }

    public func setAccount(_ id: AccountId) -> Self {
        body.cryptoGetInfo.accountID = id.toProto()

        return self
    }

    override func mapResponse(_ response: Proto_Response) throws -> AccountInfo {
        guard case .cryptoGetInfo(let response) =  response.response else { throw HederaError(message: "query response was not of type account info") }
        
        return AccountInfo(response.accountInfo)
    }
}
