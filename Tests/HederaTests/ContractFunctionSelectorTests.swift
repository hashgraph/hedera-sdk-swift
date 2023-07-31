/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2023 Hedera Hashgraph, LLC
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

import XCTest

@testable import Hedera

internal final class ContractFunctionSelectorTests: XCTestCase {
    internal func testMiscParams() {
        let result = ContractFunctionSelector("foo")
            .addUint8()
            .addInt8()
            .addUint32()
            .addInt32()
            .addUint64()
            .addInt64()
            .addUint256()
            .addInt256()
            .addUint8Array()
            .addInt8Array()
            .addUint32Array()
            .addInt32Array()
            .addUint64Array()
            .addInt64Array()
            .addUint256Array()
            .addInt256Array()
            .finish()

        XCTAssertEqual(result.hexStringEncoded(), "11bcd903")
    }

    internal func testAddress() {
        let result = ContractFunctionSelector("foo").addAddress().addAddress().addAddressArray().finish()

        XCTAssertEqual(result.hexStringEncoded(), "7d48c86d")
    }

    internal func testFunction() {
        let result = ContractFunctionSelector("foo").addFunction().addFunction().finish()

        XCTAssertEqual(result.hexStringEncoded(), "c99c40cd")
    }

    internal func testSelectorAllTypes() {
        let signature = ContractFunctionSelector("testFunction")
            .addAddress()
            .addAddressArray()
            .addBool()
            .addBytes()
            .addBytes32()
            .addBytes32Array()
            .addBytesArray()
            .addFunction()
            .addInt8()
            .addInt8Array()
            .addInt32()
            .addInt32Array()
            .addInt64()
            .addInt64Array()
            .addInt256()
            .addInt256Array()
            .addUint8()
            .addUint8Array()
            .addUint32()
            .addUint32Array()
            .addUint64()
            .addUint64Array()
            .addUint256()
            .addUint256Array()
            .addString()
            .addStringArray()
            .finish()

        XCTAssertEqual(signature.hexStringEncoded(), "4438e4ce")
    }
}
