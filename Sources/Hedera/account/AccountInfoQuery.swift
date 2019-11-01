import SwiftProtobuf
import Foundation
import Sodium

public struct AccountInfo {
    let accountId: AccountId;
    let contractAccountId: String?;
    let deleted: Bool;
    let proxyAccountId: AccountId?;
    let proxyReceived: UInt64;
    let key: KeyList;
    let balance: UInt64;
    let generateSendRecordThreshold: UInt64;
    let generateReceiveRecordThreshold: UInt64;
    let receiverSigRequired: Bool;
    let expirationTime: Date;
    let autoRenewPeriod: TimeInterval;
}

public class AccountInfoQuery: QueryBuilder<AccountInfo> {
    public override init(client: Client) {
        super.init(client: client)

        body.cryptoGetInfo = Proto_CryptoGetInfoQuery()
    }

    public func setAccount(_ id: AccountId) -> Self {
        body.cryptoGetInfo.accountID = id.toProto()

        return self
    }

    override func executeClosure(
        _ grpc: HederaGRPCClient
    ) throws -> Proto_Response {
        body.cryptoGetInfo.header = header
        return try grpc.cryptoService.getAccountInfo(body)
    }

    override func mapResponse(_ response: Proto_Response) -> AccountInfo {
        let accountInfo = response.cryptoGetInfo.accountInfo

        var proxyAccountId: AccountId? = nil
        if accountInfo.hasProxyAccountID {
            proxyAccountId = AccountId(accountInfo.proxyAccountID)
        }

        return AccountInfo(
            accountId: AccountId(accountInfo.accountID),
            contractAccountId: accountInfo.contractAccountID,
            deleted: accountInfo.deleted,
            proxyAccountId: proxyAccountId,
            proxyReceived: UInt64(accountInfo.proxyReceived),
            key: KeyList(accountInfo.key)!,
            balance: accountInfo.balance,
            generateSendRecordThreshold: accountInfo.generateSendRecordThreshold,
            generateReceiveRecordThreshold: accountInfo.generateReceiveRecordThreshold,
            receiverSigRequired: accountInfo.receiverSigRequired,
            expirationTime: Date(accountInfo.expirationTime),
            autoRenewPeriod: TimeInterval(accountInfo.autoRenewPeriod)!
        )
    }
}
