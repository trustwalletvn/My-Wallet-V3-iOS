// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinKit
import TestKit
import XCTest

class BitcoinKeyPairDeriverTests: XCTestCase {

    var subject: AnyBitcoinKeyPairDeriver!

    override func setUp() {
        super.setUp()
        subject = AnyBitcoinKeyPairDeriver()
    }

    override func tearDown() {
        subject = nil
        super.tearDown()
    }

    func test_derive_passphrase() throws {
        // Arrange
        let expectedKeyPair = BitcoinKeyPair(
            privateKey: BitcoinPrivateKey(
                xpriv: "xprv9yiFNv3Esk6JkJH1xDggWsRVp37cNbd92qEsRVMRC2Z9eJXnCDjUmmwqL6CDMc7iQjdDibUw433staJVz6RENGEeWkciWQ4kYGV5vLgv1PE"
            ),
            xpub: "xpub6ChbnRa8i7ebxnMV4FDgt1NEN4x6n4LzQ4AUDsm2kN68X6rvjm3jKaGKBQCSF4ZQ4T2ctoTtgME3uYb76ZhZ7BLNrtSQM9FXTja2cZMF8Xr"
        )
        let keyDerivationInput = BitcoinKeyDerivationInput(
            mnemonic: MockWalletTestData.Bip39.mnemonic,
            passphrase: MockWalletTestData.Bip39.passphrase
        )

        // Act
        guard let result = try? subject.derive(input: keyDerivationInput).get() else {
            XCTFail("Derivation failed")
            return
        }

        // Assert
        XCTAssertEqual(result, expectedKeyPair)
    }

    func test_derive_empty_passphrase() throws {
        // Arrange
        let expectedKeyPair = BitcoinKeyPair(
            privateKey: BitcoinPrivateKey(
                xpriv: "xprv9zDrURuhy9arxJ4tWiwnBXvcyNT88wvnSitdTnu3x6571yWTfqgyjY6TqVqhG26fy39JPdzb1VX6zXinGQtHi3Wys3qPwdkatg1KSWM2uHs"
            ),
            xpub: "xpub6DDCswSboX9AAn9MckUnYfsMXQHcYQedowpEGBJfWRc5tmqcDP1EHLQwgmXFmkYvfhNigZqUHdWJUpf6t3ufdYrdUCHUrZUhgKj3diWoSm6"
        )
        let keyDerivationInput = BitcoinKeyDerivationInput(
            mnemonic: MockWalletTestData.Bip39.mnemonic,
            passphrase: MockWalletTestData.Bip39.emptyPassphrase
        )

        // Act
        guard let result = try? subject.derive(input: keyDerivationInput).get() else {
            XCTFail("Derivation failed")
            return
        }

        // Assert
        XCTAssertEqual(result, expectedKeyPair)
    }
}
