// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureKYCUI
import XCTest

class MockKYCConfirmPhoneNumberView: KYCConfirmPhoneNumberView {
    var didCallShowLoadingViewExpectation: XCTestExpectation?
    var didCallStartVerifSuccessExpectation: XCTestExpectation?
    var didCallShowErrorExpectation: XCTestExpectation?
    var didCallHideLoadingViewExpectation: XCTestExpectation?
    var didCallConfirmCodeExpectation: XCTestExpectation?

    func showLoadingView(with text: String) {
        didCallShowLoadingViewExpectation?.fulfill()
    }

    func startVerificationSuccess() {
        didCallStartVerifSuccessExpectation?.fulfill()
    }

    func showError(message: String) {
        didCallShowErrorExpectation?.fulfill()
    }

    func hideLoadingView() {
        didCallHideLoadingViewExpectation?.fulfill()
    }

    func confirmCodeSuccess() {
        didCallConfirmCodeExpectation?.fulfill()
    }
}
