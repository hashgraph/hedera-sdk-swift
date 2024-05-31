/*
 * ‌
 * Hedera Swift SDK
 * ​
 * Copyright (C) 2022 - 2024 Hedera Hashgraph, LLC
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

import Hedera
import XCTest

internal final class ContractIdPopulation: XCTestCase {
    internal let contractByteCode =
        "608060405234801561001057600080fd5b50336000806101000a81548173ffffffffffffffffffffffffffffffffffffffff021916908373ffffffffffffffffffffffffffffffffffffffff1602179055506101cb806100606000396000f3fe608060405260043610610046576000357c01000000000000000000000000000000000000000000000000000000009004806341c0e1b51461004b578063cfae321714610062575b600080fd5b34801561005757600080fd5b506100606100f2565b005b34801561006e57600080fd5b50610077610162565b6040518080602001828103825283818151815260200191508051906020019080838360005b838110156100b757808201518184015260208101905061009c565b50505050905090810190601f1680156100e45780820380516001836020036101000a031916815260200191505b509250505060405180910390f35b6000809054906101000a900473ffffffffffffffffffffffffffffffffffffffff1673ffffffffffffffffffffffffffffffffffffffff163373ffffffffffffffffffffffffffffffffffffffff161415610160573373ffffffffffffffffffffffffffffffffffffffff16ff5b565b60606040805190810160405280600d81526020017f48656c6c6f2c20776f726c64210000000000000000000000000000000000000081525090509056fea165627a7a72305820ae96fb3af7cde9c0abfe365272441894ab717f816f07f41f07b1cbede54e256e0029"
        .data(using: .utf8)!

    internal func testPopulateContractIdNum() async throws {
        let testEnv = try TestEnvironment.nonFree

        let fileCreateReceipt = try await FileCreateTransaction()
            .keys([.single(testEnv.operator.privateKey.publicKey)])
            .contents(self.contractByteCode)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let fileId = try XCTUnwrap(fileCreateReceipt.fileId)

        let contractCreateReceipt = try await ContractCreateTransaction()
            .adminKey(.single(testEnv.operator.privateKey.publicKey))
            .gas(100000)
            .constructorParameters(ContractFunctionParameters().addString("Hello from Hedera."))
            .contractMemo("[e2e::ContractIdPopulation]")
            .bytecodeFileId(fileId)
            .execute(testEnv.client)
            .getReceipt(testEnv.client)

        let contractId = try XCTUnwrap(contractCreateReceipt.contractId)
        try await Task.sleep(nanoseconds: 5 * 1_000_000_000)

        let contractInfo = try await ContractInfoQuery(contractId: contractId).execute(testEnv.client)
        let contractIdMirror = try ContractId.fromEvmAddress(0, 0, contractInfo.contractAccountId)

        let newContractId = try await contractIdMirror.populateContractNum(testEnv.client)

        XCTAssertEqual(contractId.num, newContractId.num)
    }
}
