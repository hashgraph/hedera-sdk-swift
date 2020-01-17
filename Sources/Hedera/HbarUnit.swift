import Foundation

public enum HbarUnit {
    case Tinybar
    case Microbar
    case Millibar
    case Hbar
    case Kilobar
    case Megabar
    case Gigabar

    public var getSymbol: String {
        switch self {
        case .Tinybar:
            return "tℏ"
        case .Microbar:
            return "μℏ"
        case .Millibar:
            return "mℏ"
        case .Hbar:
            return "ℏ"
        case .Kilobar:
            return "kℏ"
        case .Megabar:
            return "Mℏ"
        case .Gigabar:
            return "Gℏ"
        }
    }

    func toTinybarCount() -> Decimal {
        let amount: UInt64
        switch self {
        case .Tinybar:
            amount = 1
        case .Microbar:
            amount = 100
        case .Millibar:
            amount = 100_000
        case .Hbar:
            amount = 100_000_000
        case .Kilobar:
            amount = 100_000_000 * 1_000
        case .Megabar:
            amount = 100_000_000 * 1_000_000
        case .Gigabar:
            amount = 100_000_000 * 1_000_000_000
        }

        return Decimal(amount)
    }
}

extension HbarUnit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .Tinybar:
            return "tinybar"
        case .Microbar:
            return "microbar"
        case .Millibar:
            return "millibar"
        case .Hbar:
            return "hbar"
        case .Kilobar:
            return "kilobar"
        case .Megabar:
            return "megabar"
        case .Gigabar:
            return "gigabar"
        }
    }
}
