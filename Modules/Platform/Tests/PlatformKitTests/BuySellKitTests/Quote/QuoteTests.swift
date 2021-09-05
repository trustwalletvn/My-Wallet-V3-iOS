// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import PlatformKit
import XCTest

final class SimpleBuyQuoteTests: XCTestCase {

    func testAllRegions() throws {
        let sut = try createTestCases(locales: [.US, .Canada, .GreatBritain, .France, .Japan, .Lithuania])
        for this in sut {
            XCTAssertNotNil(this.quote)
            XCTAssertFalse(this.quote.estimatedAmount.isZero, "\(this.locale) has zero estimatedAmount")
            XCTAssertEqual(this.quote.fee.displayMajorValue, 12.5, "\(this.locale) fee major value should be 12.5")
        }
    }
}

extension SimpleBuyQuoteTests {

    private struct QuoteTestCase {
        let locale: Locale
        let response: QuoteResponse
        let quote: Quote!
    }

    private func createTestCases(locales: [Locale]) throws -> [QuoteTestCase] {
        try locales.map { try createTestCase(locale: $0) }
    }

    private func createTestCase(locale: Locale) throws -> QuoteTestCase {
        let response = QuoteResponse(time: "2020-03-26T11:04:35.144Z", rate: "1000000", rateWithoutFee: "995000", fee: "5000")
        let twoThousandFiveHundred = FiatValue.create(minor: "250000", currency: .GBP)!
        let quote = try Quote(
            to: .coin(.bitcoin),
            amount: twoThousandFiveHundred,
            response: response
        )
        return QuoteTestCase(locale: locale, response: response, quote: quote)
    }
}
