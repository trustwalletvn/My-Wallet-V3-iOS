// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
@testable import EthereumKitMock
@testable import PlatformKit
import XCTest

class EthereumTransactionSignerTests: XCTestCase {

    var subject: EthereumTransactionSigner!
    var builder: EthereumTransactionBuilder!

    override func setUp() {
        super.setUp()
        builder = EthereumTransactionBuilder()
        subject = EthereumTransactionSigner()
    }

    override func tearDown() {
        subject = nil
        builder = nil
        super.tearDown()
    }

    func test_sign_transaction() throws {
        let amount = BigUInt("0.1", decimals: CryptoCurrency.coin(.ethereum).maxDecimalPlaces)!
        let toAddress = EthereumAddress(address: "0x3535353535353535353535353535353535353535")!
        let keyPair = MockEthereumWalletTestData.keyPair
        let candidate = EthereumTransactionCandidate(
            to: toAddress,
            gasPrice: MockEthereumWalletTestData.Transaction.gasPrice,
            gasLimit: MockEthereumWalletTestData.Transaction.gasLimit,
            value: amount,
            data: Data(),
            transferType: .transfer
        )
        guard case .success(let costed) = builder.build(transaction: candidate, nonce: 9) else {
            XCTFail("Transaction building failed")
            return
        }
        guard case .success(let signed) = subject.sign(transaction: costed, keyPair: keyPair) else {
            XCTFail("Transaction signing failed")
            return
        }
        // swiftlint:disable line_length
        let rawTransaction = "0xf86c0985028fa6ae0082520894353535353535353535353535353535353535353588016345785d8a00008026a0521f82fef48c80ca3245cc1d2be289f42f5119613fc1eea8c8e9e673d48c7b8ba017cfd25094a4f81e2c5f766e76686bc9270f22d24e8998fa1549d0c9a3d5f786"
        XCTAssertEqual(signed.encodedTransaction, Data(hexString: rawTransaction))
    }
}
