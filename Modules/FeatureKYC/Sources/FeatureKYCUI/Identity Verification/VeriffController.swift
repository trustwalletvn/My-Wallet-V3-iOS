// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import UIKit
import Veriff

protocol VeriffController: VeriffSdkDelegate {

    var veriff: VeriffSdk { get }

    // Actions

    func veriffCredentialsRequest()

    func launchVeriffController(credentials: VeriffCredentials)

    // Completion handlers

    func onVeriffSubmissionCompleted()

    func onVeriffError(message: String)

    func onVeriffCancelled()
}

extension VeriffController where Self: UIViewController {
    internal var veriff: VeriffSdk {
        VeriffSdk.shared
    }

    func launchVeriffController(credentials: VeriffCredentials) {
        veriff.delegate = self
        veriff.startAuthentication(sessionUrl: credentials.url)
    }
}

extension VeriffController {
    func sessionDidEndWithResult(_ result: VeriffSdk.Result) {

        switch result.status {
        case .error(let error):
            onVeriffError(message: error.localizedErrorMessage)
        case .done:
            onVeriffSubmissionCompleted()
        case .canceled:
            onVeriffCancelled()
        @unknown default:
            onVeriffCancelled()
        }
    }
}

extension VeriffSdk.Error {
    var localizedErrorMessage: String {
        switch self {
        case .cameraUnavailable:
            return LocalizationConstants.Errors.cameraAccessDeniedMessage
        case .microphoneUnavailable:
            return LocalizationConstants.Errors.microphoneAccessDeniedMessage
        case .deprecatedSDKVersion,
             .localError,
             .networkError,
             .serverError,
             .unknown,
             .uploadError,
             .videoFailed:
            return LocalizationConstants.Errors.genericError
        @unknown default:
            return LocalizationConstants.Errors.genericError
        }
    }
}
