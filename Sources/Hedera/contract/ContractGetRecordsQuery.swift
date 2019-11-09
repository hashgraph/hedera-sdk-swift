import Foundation

public class ContractGetRecordsQuery: QueryBuilder<[TransactionRecord]> {
    public override init(client: Client) {
        super.init(client: client)

        body.contractGetRecords = Proto_ContractGetRecordsQuery()
    }

    /// Set the contract id to get the records of.
    @discardableResult
    public func setContract(_ id: ContractId) -> Self {
        body.contractGetRecords.contractID = id.toProto()

        return self
    }

    override func mapResponse(_ response: Proto_Response) -> Result<[TransactionRecord], HederaError> {
        guard case .contractGetRecordsResponse(let response) =  response.response else {
            return .failure(HederaError(message: "query response was not of type 'contractGetRecords'"))
        }

        return .success(response.records.map(TransactionRecord.init))
    }
}
