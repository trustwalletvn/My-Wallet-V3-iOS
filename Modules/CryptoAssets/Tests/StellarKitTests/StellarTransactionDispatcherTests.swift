// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
@testable import PlatformKitMock
import RxBlocking
import RxSwift
@testable import StellarKit
@testable import StellarKitMock
import stellarsdk
import XCTest

class StellarTransactionDispatcherTests: XCTestCase {

    var sut: StellarTransactionDispatcher!

    var accountRepository: StellarWalletAccountRepositoryMock!
    var walletOptions: WalletServiceMock!
    var horizonProxy: HorizonProxyMock!

    override func setUp() {
        super.setUp()
        accountRepository = StellarWalletAccountRepositoryMock()
        walletOptions = WalletServiceMock()
        horizonProxy = HorizonProxyMock()
        sut = StellarTransactionDispatcher(
            accountRepository: accountRepository,
            walletOptions: walletOptions,
            horizonProxy: horizonProxy
        )
    }

    func testDryRunValidTransaction() throws {
        let sendDetails = SendDetails.valid()
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "100")
        let toJSON = AccountResponse.JSON.valid(accountID: sendDetails.toAddress, balance: "1")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.toAddress] = toJSON

        do {
            _ = try sut.dryRunTransaction(sendDetails: sendDetails).toBlocking().first()
        } catch {
            XCTFail(String(describing: error))
        }
    }

    private func dryRunInvalidTransaction(_ sendDetails: SendDetails, with expectedError: SendFailureReason) {
        do {
            _ = try sut.dryRunTransaction(sendDetails: sendDetails).toBlocking().first()
            XCTFail("Should have failed")
        } catch {
            if (error as? SendFailureReason) != expectedError {
                XCTFail("Unexpected error \(String(describing: error))")
            }
        }
    }

    func testDryRunTransaction_InsufficientFunds() throws {
        let sendDetails = SendDetails.valid()
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "51")
        let toJSON = AccountResponse.JSON.valid(accountID: sendDetails.toAddress, balance: "1")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.toAddress] = toJSON

        dryRunInvalidTransaction(sendDetails, with: .insufficientFunds)
    }

    func testDryRunTransaction_BelowMinimumSend_NewAccount() throws {
        let sendDetails = SendDetails.valid(value: .init(amount: 10000000, currency: .coin(.stellar)))
        horizonProxy.underlyingMinimumBalance = .create(major: 5, currency: .coin(.stellar))
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "100")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON

        dryRunInvalidTransaction(sendDetails, with: .belowMinimumSendNewAccount)
    }

    func testDryRunTransaction_BelowMinimumSend() throws {
        let sendDetails = SendDetails.valid(value: .init(amount: 1, currency: .coin(.stellar)))
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "100")
        let toJSON = AccountResponse.JSON.valid(accountID: sendDetails.toAddress, balance: "100")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.toAddress] = toJSON

        do {
            _ = try sut.dryRunTransaction(sendDetails: sendDetails).toBlocking().first()
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testDryRunTransaction_BadDestinationAccountID() throws {
        let sendDetails = SendDetails.valid(toAddress: "HDKDDBJNREDV4ITL65Z3PNKAGWYJQL7FZJSV4P2UWGLRXI6AWT36UED")
        let fromJSON = AccountResponse.JSON.valid(accountID: sendDetails.fromAddress, balance: "100")
        horizonProxy.underlyingAccountResponseJSONMap[sendDetails.fromAddress] = fromJSON

        dryRunInvalidTransaction(sendDetails, with: .badDestinationAccountID)
    }
}

extension SendDetails {
    fileprivate static func valid(
        toAddress: String = "GCJD4FLZFAEYXYLZYCNH3PVUHAQGEBLXHTJHLWXG5Q6XA6YXCPCYJGPA",
        value: CryptoValue = .create(major: 50, currency: .coin(.stellar))
    ) -> SendDetails {
        SendDetails(
            fromAddress: "GAAZI4TCR3TY5OJHCTJC2A4QSY6CJWJH5IAJTGKIN2ER7LBNVKOCCWN7",
            fromLabel: "From Label",
            toAddress: toAddress,
            toLabel: "To Label",
            value: value,
            fee: .create(major: 1, currency: .coin(.stellar)),
            memo: .text("1234567890")
        )
    }
}
