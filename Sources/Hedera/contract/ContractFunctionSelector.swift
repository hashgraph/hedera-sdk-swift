fileprivate enum Argument {
    case UInt8
    case Int8
    case UInt16
    case Int16
    case UInt32
    case Int32
    case UInt64
    case Int64
    case UInt256
    case Int256
    case String
    case Bool
    case Bytes
    case Address
    case Function
}

extension Argument {
    public var description: String {
        switch self {
        case .UInt8: return "uint8"
        case .Int8: return "int8"
        case .UInt16: return "uint16"
        case .Int16: return "int16"
        case .UInt32: return "uint32"
        case .Int32: return "int32"
        case .UInt64: return "uint64"
        case .Int64: return "int64"
        case .UInt256: return "uint256"
        case .Int256: return "int256"
        case .String: return "string"
        case .Bool: return "bool"
        case .Bytes: return "bytes"
        case .Address: return "address"
        case .Function: return "function"
        }
    }

    public var debugDescription: String {
        self.description
    }
}

struct Solidity {
    fileprivate let type: Argument
    fileprivate let array: Bool
}

extension Solidity {
    public var description: String {
        if self.array {
            return self.type.description + "[]"
        } else {
            return self.type.description
        }
    }

    public var debugDescription: String {
        self.description
    }
}
public class ContractFunctionSelector {
    fileprivate var name: String?
    fileprivate var params: String = ""
    fileprivate var types: [Solidity] = []

    public init(_ name: String?) {
        self.name =  name
    }

    @discardableResult
	public func addString() -> Self {
        self.addParam(Solidity(type: Argument.String, array: false))
        return self	}

    @discardableResult
	public func addStringArray() -> Self {
		self.addParam(Solidity(type: Argument.String, array: true))
	}

    @discardableResult
	public func addBytes() -> Self {
		self.addParam(Solidity(type: Argument.Bytes, array: false))
	}

    @discardableResult
	public func addBytesArray() -> Self {
		self.addParam(Solidity(type: Argument.Bytes, array: true))
	}

    @discardableResult
	public func addBool() -> Self {
		self.addParam(Solidity(type: Argument.Bool, array: false))
	}

    @discardableResult
	public func addInt32() -> Self {
		self.addParam(Solidity(type: Argument.UInt32, array: false))
	}

    @discardableResult
	public func addInt64() -> Self {
		self.addParam(Solidity(type: Argument.Int64, array: false))
	}

    @discardableResult
	public func addInt256() -> Self {
		self.addParam(Solidity(type: Argument.Int256, array: false))
	}

    @discardableResult
	public func addInt32Array() -> Self {
		self.addParam(Solidity(type: Argument.Int32, array: true))
	}

    @discardableResult
	public func addInt64Array() -> Self {
		self.addParam(Solidity(type: Argument.Int64, array: true))
	}

    @discardableResult
	public func addInt256Array() -> Self {
		self.addParam(Solidity(type: Argument.Int256, array: true))
	}

    @discardableResult
	public func addUInt32() -> Self {
		self.addParam(Solidity(type: Argument.UInt32, array: false))
	}

    @discardableResult
	public func addUInt64() -> Self {
		self.addParam(Solidity(type: Argument.UInt64, array: false))
	}

    @discardableResult
	public func addUInt256() -> Self {
		self.addParam(Solidity(type: Argument.UInt256, array: false))
	}

    @discardableResult
	public func addUInt32Array() -> Self {
		self.addParam(Solidity(type: Argument.UInt32, array: true))
	}

    @discardableResult
	public func addUInt64Array() -> Self {
		self.addParam(Solidity(type: Argument.UInt64, array: true))
	}

    @discardableResult
	public func addUInt256Array() -> Self {
		self.addParam(Solidity(type: Argument.UInt256, array: true))
	}

    @discardableResult
	public func addAddress() -> Self {
		self.addParam(Solidity(type: Argument.Address, array: false))
	}

    @discardableResult
	public func addAddressArray() -> Self {
		self.addParam(Solidity(type: Argument.Address, array: true))
	}

    @discardableResult
	public func addFunction() -> Self {
		self.addParam(Solidity(type: Argument.Function, array: false))
	}

    func addParam(_ type: Solidity) -> Self {
        if self.types.count > 0 {
            self.params += ","
        }

        self.params += type.description
        self.types.append(type)

        return self
    }

    public func build(name: String?) -> [UInt8] {
        if name != nil {
            self.name = name
        } else if self.name == nil {
            // TODO: Throw error
            return [0, 0, 0, 0]
        }

        // TODO: Use Keccak to hash the function signature
        return [0, 0, 0, 0]
    }
}
