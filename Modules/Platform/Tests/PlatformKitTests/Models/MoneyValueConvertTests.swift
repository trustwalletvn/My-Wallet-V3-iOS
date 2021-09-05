// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

final class MoneyValueConvertTests: XCTestCase {

    var mockCoin6Precision: CoinAssetModel {
        CoinAssetModel(
            code: "MOCK",
            name: "Mock Coin",
            precision: 6,
            products: [],
            logoPngUrl: nil,
            spotColor: nil,
            minimumOnChainConfirmations: 0,
            sortIndex: 0
        )
    }

    func testConvertingALGOIntoBTCUsingBTCExchangeRate() throws {
        let exchangeRate = CryptoValue(
            amount: 400,
            currency: .coin(.bitcoin)
        ).moneyValue
        let value = CryptoValue(
            amount: 10000,
            currency: .coin(mockCoin6Precision)
        ).moneyValue
        let expected = CryptoValue(
            amount: 4,
            currency: .coin(.bitcoin)
        ).moneyValue
        let result = try value.convert(using: exchangeRate)
        XCTAssertEqual(result, expected)
    }

    func testConvertingBTCIntoALGOUsingBTCExchangeRate() throws {
        let exchangeRate = CryptoValue(
            amount: 400,
            currency: .coin(.bitcoin)
        ).moneyValue
        let value = CryptoValue(
            amount: 4,
            currency: .coin(.bitcoin)
        ).moneyValue
        let expected = CryptoValue(
            amount: 10000,
            currency: .coin(mockCoin6Precision)
        ).moneyValue
        let result = try value.convert(
            usingInverse: exchangeRate,
            currencyType: .crypto(.coin(mockCoin6Precision))
        )
        XCTAssertEqual(result, expected)
    }
}
