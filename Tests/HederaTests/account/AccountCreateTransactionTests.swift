@testable import Hedera
import XCTest

final class AccountCreateTransactionTests: XCTestCase {
    static let allTests = [
        ("testSerializes", testSerializes)
    ]
    
    /// NOTE: This was supposed to match the Java SDK's test but it seems the serialization
    /// is ever so slightly different and nobody knows why.
    func testSerializes() {
        let date = Date(timeIntervalSince1970: 1554158542)
        let key = Ed25519PrivateKey("302e020100300506032b6570042204203b054fade7a2b0869c6bd4a63b7017cbae7855d12acc357bea718e2c3e805962")!
        let tx = try! AccountCreateTransaction()
            .setNodeAccount(AccountId(3))
            .setTransactionId(TransactionId(account: AccountId(2), validStart: date))
            .setKey(key.publicKey)
            .setInitialBalance(450)
            .setProxyAccountId(AccountId(1020))
            .setReceiverSignatureRequired(true)
            .setMaxTransactionFee(100_000)
            .build()
            .sign(with: key)
        
        let expectedOutput = "sigMap {\n  sigPair {\n    pubKeyPrefix: \"\\344\\361\\300\\353L}\\315\\303\\347\\353\\021p\\263\\b\\212=\\022\\242\\227\\364\\243\\353\\342\\362\\205\\003\\375g5F\\355\\216\"\n    ed25519: \"\\357\\204n\\334\\222L\\305\\022\\312\\034\\021\'\\324n\\201\\347+\\223w\\226\\261\\261I\\307\\fTj\\236\\213\\321?\\230\\2176\\326p\\232\\025\\207\\322\\244?\\230\\265R\\035\\177kp\\211\\342\\034\\316\\215\\260\\335Z\\267\\301\\2718\\362]\\b\"\n  }\n}\nbodyBytes: \"\\n\\f\\n\\006\\b\\316\\247\\212\\345\\005\\022\\002\\030\\002\\022\\002\\030\\003\\030\\240\\215\\006\\\"\\002\\bxZM\\n\\\"\\022 \\344\\361\\300\\353L}\\315\\303\\347\\353\\021p\\263\\b\\212=\\022\\242\\227\\364\\243\\353\\342\\362\\205\\003\\375g5F\\355\\216\\020\\302\\003\\032\\003\\030\\374\\0070\\377\\377\\377\\377\\377\\377\\377\\377\\1778\\377\\377\\377\\377\\377\\377\\377\\377\\177@\\001J\\005\\b\\320\\310\\341\\003R\\000Z\\000\"\n"

        XCTAssertEqual(tx.toProto().textFormatString(), expectedOutput)
    }
}
