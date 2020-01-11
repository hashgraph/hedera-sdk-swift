import Foundation

public class ContractGetRecordsQuery: QueryBuilder<[TransactionRecord]> {
    public override init() {
        super.init()

        body.contractGetRecords = Proto_ContractGetRecordsQuery()
    }

    /// Set the contract to get the records of.
    @discardableResult
    public func setContractId(_ id: ContractId) -> Self {
        body.contractGetRecords.contractID = id.toProto()

        return self
    }

    override func withHeader<R>(_ callback: (inout Proto_QueryHeader) -> R) -> R {
        callback(&body.contractGetRecords.header)
    }

    override func mapResponse(_ response: Proto_Response) -> [TransactionRecord] {
        guard case .contractGetRecordsResponse(let response) = response.response else {
            fatalError("unreachable: response is not contractGetRecords")
        }

        return response.records.map(TransactionRecord.init)
    }
}
