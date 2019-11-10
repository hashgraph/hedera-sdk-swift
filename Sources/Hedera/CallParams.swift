import CryptoSwift

public final class CallParams {
    private let functionSelector: FunctionSelector?
    private var args: [Argument]

    public init(funcSelector: FunctionSelector?) {
        self.functionSelector = funcSelector
        args = []
    }

    private func addParamType(paramType: String) {
        _ = try! functionSelector?.addParamType(typeName: paramType)
    }

    public func addString(param: String) -> CallParams {
        addParamType(paramType: "string")
        args.append(Argument(value: encodeString(param)))

        return self
    }

    public final class FunctionSelector {
        private var state: SelectorState
        private var needsComma: Bool

        private enum SelectorState {
            case unfinished([UInt8])
            case finished([UInt8])
        }
    
        public init(_ funcName: String) {
            needsComma = false
            // 0x28 = '('
            state = .unfinished(Array<UInt8>(funcName.utf8) + [0x28])
        }
    
        public func addParamType(typeName: String) throws -> FunctionSelector {
            guard case var .unfinished(bytes) = state else { 
                throw HederaError(message: "Can't add type params to FunctionSelectors once they have finished") 
            }

            bytes += (needsComma ? [0x23] : []) + Array<UInt8>(typeName.utf8)

            state = .unfinished(bytes)
            needsComma = true

            return self
        }
    
        public func finishIntermediate() -> [UInt8] {
            switch state {
                case let .unfinished(bytes):
                    // 0x29 = ')'
                    return Digest.sha3(bytes + [0x29], variant: .keccak256)

                case let .finished(hash):
                    return hash
            }
        }
    
        public func finish() -> [UInt8] {
            let hash = finishIntermediate()
            state = .finished(hash)

            return hash
        }
    }
}

fileprivate final class Argument {
    private let value: [UInt8]
    private let isDynamic: Bool

    // this is a different init function so that it avoids the throws annotation
    init(value: [UInt8]) {
        self.value = value
        self.isDynamic = true

    }

    init(value: [UInt8], isDynamic: Bool) throws {
        guard isDynamic || value.count == 32 else {
            throw HederaError(message: "invalid argument: value argument that was not 32 bytes") 
        }

        self.value = value
        self.isDynamic = isDynamic
    }
}

private func encodeString(_ param: String) -> [UInt8] {
    let strBytes = Array<UInt8>(param.utf8)

    // prepend the size of the string.
    return int256(val: Int64(strBytes.count), bitwidth: 32) + padRight(strBytes)
}

private func encodeBytes(bytes: [UInt8]) -> [UInt8] {
    return int256(val: Int64(bytes.count), bitwidth: 32) + padRight(bytes)
}

private func encodeArray(elements: [[UInt8]], prependLen: Bool) -> [UInt8] {
    if (prependLen) {
        return int256(val: Int64(elements.count), bitwidth: 32) + elements.joined()
    } else {
        return Array(elements.joined())
    }
}

private func int256(val: Int64, bitwidth: UInt8) -> [UInt8] {
    // this uses int internally for convinence, 
    // but uses UInt8 as a param type to ensure
    //  that nothing tries to use a bitwidth too big.
    let bytes = Int(min(bitwidth, 64) / 8)
    let remainder = rem(bytes) 
    var output = Array<UInt8>(repeating: val < 0 ? 0xff : 0x00, count: bytes + remainder)

    for i in stride(from: bytes - 1, through: 0, by: -1) {
        output[remainder + i] = UInt8(val >> (i * 8))
    }

    return output
}

private func padLeft(_ bytes: [UInt8], signExtend: Bool = false) -> [UInt8] {
    return Array<UInt8>(repeating: signExtend ? 0xff : 0x00, count: rem(bytes.count)) + bytes
}

private func padRight(_ bytes: [UInt8]) -> [UInt8] {
    return bytes + Array<UInt8>(repeating: 0x00, count: rem(bytes.count))
}

private func rem(_ val: Int) -> Int {
    guard val % 32 == 0 else {
        return 0
    }

    return 32 - val % 32
}