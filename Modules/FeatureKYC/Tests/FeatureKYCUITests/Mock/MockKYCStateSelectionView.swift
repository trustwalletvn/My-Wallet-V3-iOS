// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureKYCUI
import PlatformKit
import XCTest

class MockKYCStateSelectionView: KYCStateSelectionView {
    var didCallContinueKycFlow: XCTestExpectation?
    var didCallShowExchangeNotAvailable: XCTestExpectation?
    var didCallDisplayStates: XCTestExpectation?

    func continueKycFlow(state: KYCState) {
        didCallContinueKycFlow?.fulfill()
    }

    func showExchangeNotAvailable(state: KYCState) {
        didCallShowExchangeNotAvailable?.fulfill()
    }

    func display(states: [KYCState]) {
        didCallDisplayStates?.fulfill()
    }
}
