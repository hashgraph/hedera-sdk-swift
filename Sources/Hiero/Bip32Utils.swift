/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2025 Hiero LLC
 * ​
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ‍
 */

public class Bip32Utils {
    static let hardenedMask: Int32 = 1 << 31

    public init() {}

    /// Harden the index
    public static func toHardenedIndex(_ index: UInt32) -> Int32 {
        let index = Int32(bitPattern: index)

        return (index | hardenedMask)
    }

    /// Check if the index is hardened
    public static func isHardenedIndex(_ index: UInt32) -> Bool {
        let index = Int32(bitPattern: index)

        return (index & hardenedMask) != 0
    }
}
