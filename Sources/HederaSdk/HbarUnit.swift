//
// Created by Andrei Kuz on 10/7/21.
//

import Foundation

enum HbarUnit: UInt64{
    case tinybar = 1, microbar = 100 , millibar = 100000, hbar = 100000000, kilobar = 100000000000,
         megabar = 100000000000000, gigabar = 100000000000000000
}

func getHbarUnitSymbol(_ hbarUnit: HbarUnit) -> String {
    switch hbarUnit {
    case .tinybar:
        return "tℏ"
    case .microbar:
        return "μℏ"
    case .millibar:
        return "mℏ"
    case .hbar:
        return "ℏ"
    case .kilobar:
        return "kℏ"
    case .megabar:
        return "Mℏ"
    case .gigabar:
        return "Gℏ"
    }
}

func hbarUnitToString(_ hbarUnit: HbarUnit) -> String {
    switch hbarUnit {
    case .tinybar:
        return "tinybar"
    case .microbar:
        return "microbar"
    case .millibar:
        return "millibar"
    case .hbar:
        return "hbar"
    case .kilobar:
        return "kilobar"
    case .megabar:
        return "megabar"
    case .gigabar:
        return "gigabar"
    }
}
