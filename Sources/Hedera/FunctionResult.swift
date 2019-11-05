import Foundation

public class FunctionResult {
    let contractId: ContractId
    let contractCallResult: [UInt8]
    let errorMessage: String
    let bloom: [UInt8]
    let gasUsed: Int64
    // todo let logInfoList: [ContractLogInfo]

    init(
        id contractId: ContractId,
        result contractCallResult: [UInt8],
        errorMessage: String,
        bloom: [UInt8],
        gasUsed: Int64
    ) {
        self.contractId = contractId
        self.contractCallResult = contractCallResult
        self.errorMessage = errorMessage
        self.bloom = bloom
        self.gasUsed = gasUsed
    }

    public func getString(_ index: Int) -> String? {
        return String(bytes: getBytes(index), encoding: .utf8)
    }

    public func getBytes(_ index: Int) -> [UInt8] {
        // index * 32 is the position of the lenth
        // (index + 1) * 32 onward to (index + 1) * 32 + (len * 32) will be the elements of the array
        // Arrays in solidity cannot be longer than 1024:
        // https://solidity.readthedocs.io/en/v0.4.21/introduction-to-smart-contracts.html
        let len = Int(getUInt32(index))
        return Array(contractCallResult[((index + 1) * 32)..<((index + 1) * 32 + len * 32)])
    }

    public func getBytes32(_ index: Int) -> [UInt8] {
        return Array(contractCallResult[(index * 32)..<((index + 1) * 32)])
    }

    public func getUInt64(_ index: Int) -> UInt64 {
        let source = contractCallResult[(index * 32 + 24)..<((index + 1) * 32)]
        return UInt64(bigEndian: source.withUnsafeBytes { $0.load(as: UInt64.self) })
    }

    public func getUInt32(_ index: Int) -> UInt32 {
        let slice = contractCallResult[(index * 32 + 28)..<((index + 1) * 32)]
        // For some reason this generates better code than the version getUInt64 uses. But only on UInt32s.
        return (UInt32(slice[0]) << 24) | 
               (UInt32(slice[1]) << 16) |
               (UInt32(slice[2]) <<  8) |
               (UInt32(slice[3]) <<  0)
    }

    public func getInt64(_ index: Int) -> Int64 {
        return Int64(getUInt64(index))
    }

    public func getInt32(_ index: Int) -> Int32 {
        return Int32(getUInt32(index))
    }

    public func getBool(_ index: Int) -> Bool {
        return contractCallResult[index * 32 + 31] != 0
    }

    public func getAddress(_ index: Int) -> [UInt8] {
        return Array(contractCallResult[(index * 32 + 12)..<((index + 1) * 32)])
    }
}
