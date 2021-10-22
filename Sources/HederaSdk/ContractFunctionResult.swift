import Foundation
import HederaProtoServices

public final class ContractFunctionResult {
  public let contractId: ContractId?
  public let contractCallResult: Data
  public let errorMessage: String
  public let bloom: Data
  public let gasUsed: UInt64
  public let logInfo: [ContractLogInfo]
  public let createdContractIds: [ContractId]

  init(
    _ contractId: ContractId?, _ contractCallResult: Data, _ errorMessage: String, _ bloom: Data,
    _ gasUsed: UInt64, _ logInfo: [ContractLogInfo], _ createdContractIds: [ContractId]
  ) {
    self.contractId = contractId
    self.contractCallResult = contractCallResult
    self.errorMessage = errorMessage
    self.bloom = bloom
    self.gasUsed = gasUsed
    self.logInfo = logInfo
    self.createdContractIds = createdContractIds
  }
}

extension ContractFunctionResult: ProtobufConvertible {
  convenience init?(_ proto: Proto_ContractFunctionResult) {
    self.init(
      proto.hasContractID ? ContractId(proto.contractID) : nil, proto.contractCallResult,
      proto.errorMessage, proto.bloom,
      proto.gasUsed, proto.logInfo.map { ContractLogInfo($0)! },
      proto.createdContractIds.map { ContractId($0) })
  }

  func toProtobuf() -> Proto_ContractFunctionResult {
    var proto = Proto_ContractFunctionResult()
    proto.contractCallResult = contractCallResult
    proto.errorMessage = errorMessage
    proto.bloom = bloom
    proto.gasUsed = gasUsed
    proto.logInfo = logInfo.map { $0.toProtobuf() }
    proto.createdContractIds = createdContractIds.map { $0.toProtobuf() }

    if let contractId = contractId {
      proto.contractID = contractId.toProtobuf()
    }

    return proto
  }
}

protocol DataConvertible {
  init?(data: Data)
  var data: Data { get }
}

extension DataConvertible where Self: ExpressibleByIntegerLiteral {

  init?(data: Data) {
    var value: Self = 0
    guard data.count == MemoryLayout.size(ofValue: value) else { return nil }
    _ = withUnsafeMutableBytes(of: &value, { data.copyBytes(to: $0) })
    self = value
  }

  var data: Data {
    withUnsafeBytes(of: self) { Data($0) }
  }
}

extension Int: DataConvertible {}
extension Int32: DataConvertible {}
extension Int64: DataConvertible {}

extension ContractFunctionResult {
  public func getInt8(_ index: UInt64) -> Int8 {
    Int8(contractCallResult[Int(index) * 32 + 31])
  }

  public func getInt32(_ index: UInt64) -> Int32 {
    let subdataUsingIndex = contractCallResult[(index * 32) + 28..<(index + 1) * 32]
    return Int32(data: subdataUsingIndex)!
  }

  public func getInt64(_ index: UInt64) -> Int64 {
    let subdataUsingIndex = contractCallResult[(index * 32) + 24..<(index + 1) * 32]
    return Int64(data: subdataUsingIndex)!
  }
}
