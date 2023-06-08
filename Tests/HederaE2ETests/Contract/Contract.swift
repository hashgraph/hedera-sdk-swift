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
 
import Hedera
import XCTest

internal enum ContractHelpers {}

extension ContractHelpers {
    internal static let bytecode = """
        608060405234801561001057600080fd5b506040516104d73803806104d7833981810160405260208110156100\
        3357600080fd5b810190808051604051939291908464010000000082111561005357600080fd5b908301906020\
        82018581111561006857600080fd5b825164010000000081118282018810171561008257600080fd5b82525081\
        516020918201929091019080838360005b838110156100af578181015183820152602001610097565b50505050\
        905090810190601f1680156100dc5780820380516001836020036101000a031916815260200191505b50604052\
        5050600080546001600160a01b0319163317905550805161010890600190602084019061010f565b50506101aa\
        565b828054600181600116156101000203166002900490600052602060002090601f016020900481019282601f\
        1061015057805160ff191683800117855561017d565b8280016001018555821561017d579182015b8281111561\
        017d578251825591602001919060010190610162565b5061018992915061018d565b5090565b6101a791905b80\
        8211156101895760008155600101610193565b90565b61031e806101b96000396000f3fe608060405234801561\
        001057600080fd5b50600436106100415760003560e01c8063368b87721461004657806341c0e1b5146100ee57\
        8063ce6d41de146100f6575b600080fd5b6100ec6004803603602081101561005c57600080fd5b810190602081\
        01813564010000000081111561007757600080fd5b82018360208201111561008957600080fd5b803590602001\
        918460018302840111640100000000831117156100ab57600080fd5b91908080601f0160208091040260200160\
        405190810160405280939291908181526020018383808284376000920191909152509295506101739450505050\
        50565b005b6100ec6101a2565b6100fe6101ba565b604080516020808252835181830152835191928392908301\
        9185019080838360005b83811015610138578181015183820152602001610120565b5050505090509081019060\
        1f1680156101655780820380516001836020036101000a031916815260200191505b5092505050604051809103\
        90f35b6000546001600160a01b0316331461018a5761019f565b805161019d906001906020840190610250565b\
        505b50565b6000546001600160a01b03163314156101b85733ff5b565b60018054604080516020601f60026000\
        196101008789161502019095169490940493840181900481028201810190925282815260609390929091830182\
        8280156102455780601f1061021a57610100808354040283529160200191610245565b82019190600052602060\
        0020905b81548152906001019060200180831161022857829003601f168201915b505050505090505b90565b82\
        8054600181600116156101000203166002900490600052602060002090601f016020900481019282601f106102\
        9157805160ff19168380011785556102be565b828001600101855582156102be579182015b828111156102be57\
        82518255916020019190600101906102a3565b506102ca9291506102ce565b5090565b61024d91905b80821115\
        6102ca57600081556001016102d456fea264697066735822122084964d4c3f6bc912a9d20e14e449721012d625\
        aa3c8a12de41ae5519752fc89064736f6c63430006000033
        """.data(using: .utf8)!
}
