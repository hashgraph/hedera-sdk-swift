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

import CommonCrypto
import CryptoKit
import XCTest

@testable import Hedera

internal final class CryptoAesTests: XCTestCase {
    internal static var testPassphrase = "testpassphrase13d14"

    internal func testAesDecryption() throws {
        let s = """
            -----BEGIN EC PRIVATE KEY-----
            Proc-Type: 4,ENCRYPTED
            DEK-Info: AES-128-CBC,0046A9EED8D16BE8BD6F0CAA6A197CE8

            9VU9gReUmrn4XswjMx0F0A3oGzoHIksEXma72TCSdcxI7zHy0mtzuGq4Wd25O38s
            H9c6kvhTPS1N/c6iNhc154B0HUoND8jvAvfxbGR/R87vpZUsOoKCmRxGqrxG8HER
            FIHQ2jy16DrAbi95kDyLsiF1dy2vUY/HoqFZwxl/IVc=
            -----END EC PRIVATE KEY-----
            """

        let iv = Data(hexEncoded: "0046A9EED8D16BE8BD6F0CAA6A197CE8")!

        let doc = try Crypto.Pem.decode(s)

        var hash = CryptoKit.Insecure.MD5()

        hash.update(data: Self.testPassphrase.data(using: .utf8)!)
        hash.update(data: iv[slicing: ..<8]!)

        let password = Data(hash.finalize().bytes)

        let decrypted = try Crypto.Aes.aes128CbcPadDecrypt(key: password, iv: iv, message: doc.der)

        XCTAssertEqual(
            decrypted.base64EncodedString(),
            "DZTOu2UR2ka4AD9DJWfpgutyZARbNLa6rwzp+BvBv9et9viNd/UEPlYzWRZh4W2iehbSAjzxYVEKtM78FMHOeAZq6qm+DUOth+vu6cBth2j+pD2R4+BhZWuPLKtC34mixoL2EZ7VazHcwXeNjYKxkyq3doQwsd45bdPKbQdWxbY="
        )
    }
}
