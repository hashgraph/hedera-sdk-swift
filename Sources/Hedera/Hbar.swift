import Foundation

public struct Hbar {
    private let tinybar: Int64

    private init(tinybar: Int64) {
        self.tinybar = tinybar
    }

    public static let MAX = Hbar(tinybar: Int64.max)
    public static let MIN = Hbar(tinybar: Int64.min)
    public static let ZERO = Hbar(tinybar: 0)

    public init?(hbar: Decimal) {
        let tinybarAmount = hbar * HbarUnit.Hbar.toTinybarCount()
        guard let tinybar = Int64(exactly: NSDecimalNumber(decimal: tinybarAmount)) else { return nil }

        self.init(tinybar: tinybar)
    }

    public static func from(amount: Decimal, unit: HbarUnit) -> Self? {
        guard let tinybar = Int64(exactly: NSDecimalNumber(decimal: amount * unit.toTinybarCount())) else { return nil }

        return Self(tinybar: tinybar)
    }

    public static func from(amount: Int64, unit: HbarUnit) -> Self? {
        guard let tinybar = Int64(exactly: NSDecimalNumber(decimal: Decimal(amount) * unit.toTinybarCount())) else { return nil }

        return Self(tinybar: tinybar)
    }

    public static func fromTinybar(amount: Int64) -> Self {
        Self(tinybar: amount)
    }

    public func `as`(unit: HbarUnit) -> Decimal {
        if unit == .Tinybar {
            return Decimal(tinybar)
        }
        return Decimal(tinybar) / unit.toTinybarCount()
    }

    public func asTinybar() -> Int64 {
        return tinybar
    }
}

extension Hbar: CustomStringConvertible {
    public var description: String {
        if Decimal(tinybar) < HbarUnit.Hbar.toTinybarCount() {
            return "\(tinybar) \(HbarUnit.Tinybar.getSymbol)"
        }
        return "\(Decimal(tinybar) / HbarUnit.Hbar.toTinybarCount()) \(HbarUnit.Hbar.getSymbol) (\(tinybar) tinybar)"
    }
}

extension Hbar: Comparable {
    public static func < (lhs: Hbar, rhs: Hbar) -> Bool {
        return lhs.tinybar < rhs.tinybar
    }

    public static func == (lhs: Hbar, rhs: Hbar) -> Bool {
        return lhs.tinybar == rhs.tinybar
    }
}
