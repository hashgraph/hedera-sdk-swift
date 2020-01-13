import Foundation

fileprivate struct Argument {
    fileprivate let dynamic: Bool
    fileprivate let value: Data
}

public class ContractFunctionParams {
    fileprivate var selector: ContractFunctionSelector = ContractFunctionSelector(nil)
    fileprivate var types: [Argument] = []

      public init() {}

    @discardableResult
    public func addString(_ value: String) -> Self {
        self.selector.addString()
        return self
    }

    @discardableResult
    public func addStringArray(_ value: [String]) -> Self {
        self.selector.addStringArray()
        return self
    }

    @discardableResult
    public func addBytes(_ value: [UInt8]) -> Self {
        self.selector.addBytes()
        return self
    }

    @discardableResult
    public func addBytesArray(_ value: [[UInt8]]) -> Self {
        self.selector.addBytesArray()
        return self
    }

    @discardableResult
    public func addBool(_ value: Bool) -> Self {
        self.selector.addBool()
        return self
    }

    @discardableResult
    public func addInt32(_ value: Int32) -> Self {
        self.selector.addInt32()
        var buffer = Array(repeating: UInt8(0), count: 32)
        let bytes = value.asBytes()
        buffer.replaceSubrange(28...32, with: bytes)
        return self
    }

    @discardableResult
    public func addInt64(_ value: Int64) -> Self {
        self.selector.addInt64()
        return self
    }

    @discardableResult
    public func addInt256(_ value: [UInt8]) -> Self {
        self.selector.addInt256()
        return self
    }

    @discardableResult
    public func addInt32Array(_ value: [Int32]) -> Self {
        self.selector.addInt32Array()
        return self
    }

    @discardableResult
    public func addInt64Array(_ value: [Int64]) -> Self {
        self.selector.addInt64Array()
        return self
    }

    @discardableResult
    public func addInt256Array(_ value: [[UInt8]]) -> Self {
        self.selector.addInt256Array()
        return self
    }

    @discardableResult
    public func addUInt32(_ value: UInt32) -> Self {
        self.selector.addUInt32()
        return self
    }

    @discardableResult
    public func addUInt64(_ value: UInt64) -> Self {
        self.selector.addUInt64()
        return self
    }

    @discardableResult
    public func addUInt256(_ value: [[UInt8]]) -> Self {
        self.selector.addUInt256()
        return self
    }

    @discardableResult
    public func addUInt32Array(_ value: [UInt32]) -> Self {
        self.selector.addUInt32Array()
        return self
    }

    @discardableResult
    public func addUInt64Array(_ value: [UInt64]) -> Self {
        self.selector.addUInt64Array()
        return self
    }

    @discardableResult
    public func addUInt256Array(_ value: [[UInt8]]) -> Self {
        self.selector.addUInt256Array()
        return self
    }

    @discardableResult
    public func addAddress(_ value: String) -> Self {
        self.selector.addAddress()
        return self
    }

    @discardableResult
    public func addAddressArray(_ value: [String]) -> Self {
        self.selector.addAddressArray()
        return self
    }

    @discardableResult
    public func addFunction(_ address: String, _ selector: ContractFunctionSelector) -> Self {
        self.selector.addFunction()
        return self
    }
}

