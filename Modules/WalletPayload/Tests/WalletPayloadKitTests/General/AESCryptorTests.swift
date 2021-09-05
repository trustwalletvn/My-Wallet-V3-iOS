// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import WalletPayloadKit
import XCTest

class AESCryptorTests: XCTestCase {

    private var subject: AESCryptor!

    override func setUpWithError() throws {
        try super.setUpWithError()

        subject = AESCryptor()
    }

    override func tearDownWithError() throws {
        subject = nil

        try super.tearDownWithError()
    }

    func test_encrypt_decrypt() throws {

        struct TestItem {
            let payload: Data
            let key: Data
            let iv: Data
        }

        func runTest(for item: TestItem) throws {

            func encrypt(payload: Data, key: Data, iv: Data) throws -> Data {
                let result = try subject.encrypt(data: payload, with: key, iv: iv).get()
                return Data(result)
            }

            func decrypt(payload: Data, key: Data, iv: Data) throws -> Data {
                let result = try subject.decrypt(data: payload, with: key, iv: iv).get()
                return Data(result)
            }

            let payload = item.payload
            let key = item.key
            let iv = item.iv

            let encryptedData = try encrypt(payload: payload, key: key, iv: iv)
            let decryptedData = try decrypt(payload: encryptedData, key: key, iv: iv)
            XCTAssertEqual(decryptedData, payload)
        }

        let tests = [
            TestItem(
                payload: Data(hex: "6bc1bee22e409f96e93d7e117393172a"),
                key: Data(hex: "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"),
                iv: Data(hex: "000102030405060708090A0B0C0D0E0F")
            ),
            TestItem(
                payload: Data(hex: "ae2d8a571e03ac9c9eb76fac45af8e51"),
                key: Data(hex: "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"),
                iv: Data(hex: "F58C4C04D6E5F1BA779EABFB5F7BFBD6")
            ),
            TestItem(
                payload: Data(hex: "30c81c46a35ce411e5fbc1191a0a52ef"),
                key: Data(hex: "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"),
                iv: Data(hex: "9CFC4E967EDB808D679F777BC6702C7D")
            ),
            TestItem(
                payload: Data(hex: "f69f2445df4f9b17ad2b417be66c3710"),
                key: Data(hex: "603deb1015ca71be2b73aef0857d77811f352c073b6108d72d9810a30914dff4"),
                iv: Data(hex: "39F23369A9D9BACFA530E26304231461")
            )
        ]

        for item in tests {
            try runTest(for: item)
        }
    }
}
