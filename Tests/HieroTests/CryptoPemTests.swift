// SPDX-License-Identifier: Apache-2.0

import HederaProtobufs
import SnapshotTesting
import XCTest

@testable import Hedera

internal final class CryptoPemTests: XCTestCase {
    internal func testLabelType() throws {
        let pemString =
            """
            -----BEGIN PRIVATE KEY-----
            MIGbMFcGCSqGSIb3DQEFDTBKMCkGCSqGSIb3DQEFDDAcBAjeB6TNNQX+1gICCAAw
            -----END PRIVATE KEY-----
            """

        let doc = try Crypto.Pem.decode(pemString)

        XCTAssertEqual(doc.typeLabel, "PRIVATE KEY")
    }

    internal func testExceedsLineLimitFail() throws {
        let pemString =
            """
            -----BEGIN PRIVATE KEY-----
            MIGbMFcGCSqGSIb3DQEFDTBKMCkGCSqGSIb3DQEFDDAcBAjeB6TNNQX+1gICCAAwMIGb
            -----END PRIVATE KEY-----
            """

        XCTAssertThrowsError(try Crypto.Pem.decode(pemString))
    }

    internal func testShortLineFail() throws {
        let pemString =
            """
            -----BEGIN PRIVATE KEY-----
            MIGbMFcGCSqGSIb3DQEFDTBKMCkGCSqGSIb3DQEFD
            -----END PRIVATE KEY-----
            """

        XCTAssertThrowsError(try Crypto.Pem.decode(pemString))
    }

    internal func testNonBase64CharacterFail() throws {
        let pemString =
            """
            -----BEGIN PRIVATE KEY-----
            ≈MIGbMFcGCSqGSIb3DQEFDTBKMCkGCSqGSIb3DQEFDDAcBAjeB6TNNQX+1gICCAAw
            -----END PRIVATE KEY-----
            """

        XCTAssertThrowsError(try Crypto.Pem.decode(pemString))
    }

    internal func testBadHeaderFail() throws {
        let pemString =
            """
            -----BEGIN PRIVATE KEYS-----
            MIGbMFcGCSqGSIb3DQEFDSTBKMCkGCSqGSIb3DQEFDDAcBAjeB6TNNQX+1gICCAAw
            -----END PRIVATE KEY-----
            """

        XCTAssertThrowsError(try Crypto.Pem.decode(pemString))
    }

    internal func testBadFooterFail() throws {
        let pemString =
            """
            -----BEGIN PRIVATE KEY-----
            MIGbMFcGCSqGSIb3DQEFDSTBKMCkGCSqGSIb3DQEFDDAcBAjeB6TNNQX+1gICCAAw
            -----END PRIVATE KEYS-----
            """

        XCTAssertThrowsError(try Crypto.Pem.decode(pemString))
    }

    internal func testBase64CharacterFail() throws {
        let pemString =
            """
            -----BEGIN PRIVATE KEY-----
            @IGbMFcGCSqGSIb3DQEFDTBKMCkGCSqGSIb3DQEFDDAcBAjeB6TNNQX+1gICCAAw
            -----END PRIVATE KEY-----
            """

        XCTAssertThrowsError(try Crypto.Pem.decode(pemString))
    }
}
