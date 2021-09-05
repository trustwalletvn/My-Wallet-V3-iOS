// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

class SuggestedAmountsTests: XCTestCase {

    func testDecoding() throws {
        let decoder = JSONDecoder()
        let data: Data = SuggestedAmountsTests.json.data(using: .utf8)!
        let decoded: SuggestedAmountsResponse! = try? decoder.decode(SuggestedAmountsResponse.self, from: data)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.amounts.count, 2)
        guard let response = decoded else { return }
        let amounts = SuggestedAmounts(response: response)
        XCTAssertEqual(amounts[.EUR].count, 3)
        XCTAssertEqual(amounts[.GBP].count, 3)
    }

    func testDecodingInvalidJSON() throws {
        let decoder = JSONDecoder()
        let data: Data = SuggestedAmountsTests.invalidJson.data(using: .utf8)!
        let decoded: SuggestedAmountsResponse! = try? decoder.decode(SuggestedAmountsResponse.self, from: data)
        XCTAssertNotNil(decoded)
        XCTAssertEqual(decoded?.amounts.count, 3)
        guard let response = decoded else { return }
        let amounts = SuggestedAmounts(response: response)
        XCTAssertEqual(amounts[.EUR].count, 3)
        XCTAssertEqual(amounts[.GBP].count, 3)
    }

    private static let json = """
    [
      {
        "EUR": [
          "25000",
          "50000",
          "100000"
        ]
      },
      {
        "GBP": [
          "25000",
          "50000",
          "100000"
        ]
      }
    ]
    """

    private static let invalidJson = """
    [
      {
        "not_a_currency": [
          "25000",
          "50000",
          "100000"
        ]
      },
      {
        "EUR": [
        "25000",
        "50000",
        "100000"
        ]
      },
      {
        "GBP": [
          "25000",
          "50000",
          "100000"
        ]
      }
    ]
    """
}
