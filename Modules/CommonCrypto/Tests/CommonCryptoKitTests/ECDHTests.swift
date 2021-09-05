// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import XCTest

class ECDHTests: XCTestCase {
    let privateKeyData = Data(hexString: "63a2dfd3ed1a4a8365b1df0437f1860ab7b8de73afdcc1e0aebf1d4c64d4e7c5")!
    let publicKeyData = Data(hexString: "0204a157928751500c12388d8995b7914b32901979be499602638e6133b64746f9")!
    let sharedKeyData = Data(hexString: "6b00840abb1cac475da02b453ab413309cad1b957c76d8e5e8b2bb3a1f1c4417")!

    func testECDHDerivation() throws {
        let result = (try? ECDH.derive(priv: privateKeyData, pub: publicKeyData).get().hexString) ?? ""
        XCTAssertEqual(sharedKeyData.hexString, result)
    }

    func testPublicKeyFromPrivate() throws {
        let walletcore = try ECDH.publicFromPrivate(priv: privateKeyData).get()
        XCTAssertEqual(walletcore.hexString, "02e280656c9e0ae6cfa7ca319a33eac7e0b1b94b811f50a5d2bb89a52a89810558")
    }

    func testSameSharedSecret() throws {
        let priv = "9cd3b16e10bd574fed3743d8e0de0b7b4e6c69f3245ab5a168ef010d22bfefa0"
        let pub = "02a18a98316b5f52596e75bfa5ca9fa9912edd0c989b86b73d41bb64c9c6adb992"
        let result = try ECDH.derive(priv: Data(hex: priv), pub: Data(hex: pub)).get()
        XCTAssertEqual(result.hexValue, "c87e593a1b22bad696489aa7c240356ffc8ff453d4637dc9cd32b4696df93f5c")
    }

    func testDecrypt() throws {
        let secret = "9cd3b16e10bd574fed3743d8e0de0b7b4e6c69f3245ab5a168ef010d22bfefa0"
        let testVector = "83e77704adf28646b602047763a179b5991a5d5d4457658200c84936c71e5e7ffb54a1dcf665d836cb2ce34a471747eb64392e80"
        let result = try ECDH.decrypt(priv: Data(hex: secret), payload: Data(hex: testVector)).get()
        XCTAssertEqual(String(decoding: result, as: UTF8.self), "This is a test sentence!")
    }
}
