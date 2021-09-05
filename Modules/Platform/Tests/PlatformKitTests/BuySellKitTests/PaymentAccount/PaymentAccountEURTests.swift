// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
@testable import PlatformKitMock
import XCTest

class PaymentAccountEURTests: XCTestCase {
    let sut = PaymentAccountEUR.self

    func testItsStaticCurrencyIsEUR() {
        XCTAssertEqual(sut.currency, .EUR, "currency must be EUR")
    }

    func testInitWithEmptyResponse() {
        let mock = PaymentAccountResponse.mock(with: .EUR, agent: .emptyMock)
        let account = sut.init(response: mock.account)
        XCTAssertNil(account, "SimpleBuyPaymentAccountEUR initiated with a empty agent mock should be nil")
    }

    func testInitWithWrongCurrency() {
        let mock = PaymentAccountResponse.mock(with: .GBP, agent: .fullMock)
        let account = sut.init(response: mock.account)
        XCTAssertNil(account, "SimpleBuyPaymentAccountEUR initiated with wrong currency response should be nil")
    }

    func testInitWithMinimalResponse() {
        let mock = PaymentAccountResponse.mock(with: .EUR, agent: .minimumEURMock)
        let account = sut.init(response: mock.account)
        XCTAssertNotNil(account, "SimpleBuyPaymentAccountEUR initiated with the minimal EUR agent mock should not be nil")

        XCTAssertEqual(account!.identifier, mock.id, "its id comes from the response object")
        XCTAssertEqual(account!.state, mock.state, "its state comes from the response object")
        XCTAssertEqual(account!.currency.currency, mock.currency, "its currency comes from the response object")

        XCTAssertEqual(account!.bankName, mock.agent.name, "its bankName comes from response.agent")
        XCTAssertEqual(account!.bankCountry, "", "its bankCountry is empty")
        XCTAssertEqual(account!.iban, mock.address, "its iban comes from response.address")
        XCTAssertEqual(account!.bankCode, mock.agent.code, "its bankCode comes from response.agent")
        XCTAssertEqual(account!.recipientName, "", "its recipientName is empty")
    }

    func testInitWithIdealResponse() {
        let mock = PaymentAccountResponse.mock(with: .EUR, agent: .idealEURMock)
        let account = sut.init(response: mock.account)
        XCTAssertNotNil(account, "SimpleBuyPaymentAccountEUR initiated with the minimal EUR agent mock should not be nil")

        XCTAssertEqual(account!.identifier, mock.id, "its id comes from the response object")
        XCTAssertEqual(account!.state, mock.state, "its state comes from the response object")
        XCTAssertEqual(account!.currency.currency, mock.currency, "its currency comes from the response object")

        XCTAssertEqual(account!.bankName, mock.agent.name, "its bankName comes from response.agent")
        XCTAssertEqual(account!.bankCountry, mock.agent.country, "its bankCountry comes from response.agent")
        XCTAssertEqual(account!.iban, mock.address, "its iban comes from response.address")
        XCTAssertEqual(account!.bankCode, mock.agent.code, "its bankCode comes from response.agent")
        XCTAssertEqual(account!.recipientName, mock.agent.recipient, "its recipientName comes from response.agent")
    }
}
