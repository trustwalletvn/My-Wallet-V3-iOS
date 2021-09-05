// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
@testable import PlatformKitMock
import XCTest

class PaymentAccountGBPTests: XCTestCase {
    let sut = PaymentAccountGBP.self

    func testItsStaticCurrencyIsEUR() {
        XCTAssertEqual(sut.currency, .GBP, "currency must be GBP")
    }

    func testInitWithEmptyResponse() {
        let mock = PaymentAccountResponse.mock(with: .GBP, agent: .emptyMock)
        let account = sut.init(response: mock.account)
        XCTAssertNil(account, "PaymentAccountGBP initiated with a empty agent mock should be nil")
    }

    func testInitWithWrongCurrency() {
        let mock = PaymentAccountResponse.mock(with: .EUR, agent: .fullMock)
        let account = sut.init(response: mock.account)
        XCTAssertNil(account, "PaymentAccountGBP initiated with wrong currency response should be nil")
    }

    func testInitWithMinimalResponse() {
        let mock = PaymentAccountResponse.mock(with: .GBP, agent: .minimumGBPMock)
        let account = sut.init(response: mock.account)
        XCTAssertNotNil(account, "PaymentAccountGBP initiated with the minimal EUR agent mock should not be nil")

        XCTAssertEqual(account!.identifier, mock.id, "its id comes from the response object")
        XCTAssertEqual(account!.state, mock.state, "its state comes from the response object")
        XCTAssertEqual(account!.currency.currency, mock.currency, "its currency comes from the response object")

        XCTAssertEqual(account!.accountNumber, mock.agent.account, "its accountNumber comes from response.agent")
        XCTAssertEqual(account!.sortCode, mock.agent.code, "its sortCode comes from response.agent")
        XCTAssertEqual(account!.recipientName, mock.agent.recipient, "its recipientName comes from response.agent")
    }
}
