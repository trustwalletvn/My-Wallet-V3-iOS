// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureKYCUI
import PlatformKit
import XCTest

class MockKYCCountrySelectionView: KYCCountrySelectionView {
    var didCallContinueKycFlow: XCTestExpectation?
    var didCallStartPartnerExchangeFlow: XCTestExpectation?
    var didCallShowExchangeNotAvailable: XCTestExpectation?

    func continueKycFlow(country: CountryData) {
        didCallContinueKycFlow?.fulfill()
    }

    func startPartnerExchangeFlow(country: CountryData) {
        didCallStartPartnerExchangeFlow?.fulfill()
    }

    func showExchangeNotAvailable(country: CountryData) {
        didCallShowExchangeNotAvailable?.fulfill()
    }
}
