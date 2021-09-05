// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import ToolKit

public protocol CameraPrompting: AnyObject {
    var permissionsRequestor: PermissionsRequestor { get set }
    var cameraPromptingDelegate: CameraPromptingDelegate? { get set }

    // Call this when an action requires camera usage
    func willUseCamera()

    func requestCameraPermissions()
}

extension CameraPrompting where Self: MicrophonePrompting {
    public func willUseCamera() {
        if PermissionsRequestor.shouldDisplayCameraPermissionsRequest() {
            cameraPromptingDelegate?.promptToAcceptCameraPermissions(confirmHandler: {
                self.requestCameraPermissions()
            })
            return
        }
        if PermissionsRequestor.cameraRefused() == false {
            willUseMicrophone()
        } else {
            cameraPromptingDelegate?.showCameraPermissionsDenied()
        }
    }

    public func requestCameraPermissions() {
        permissionsRequestor.requestPermissions([.camera]) { [weak self] in
            guard let this = self else { return }
            switch PermissionsRequestor.cameraEnabled() {
            case true:
                this.willUseMicrophone()
            case false:
                this.cameraPromptingDelegate?.showCameraPermissionsDenied()
            }
        }
    }
}

public protocol CameraPromptingDelegate: AnyObject {
    var analyticsRecorder: AnalyticsEventRecorderAPI { get }

    func showCameraPermissionsDenied()
    func promptToAcceptCameraPermissions(confirmHandler: @escaping (() -> Void))
}

extension CameraPromptingDelegate {
    public func showCameraPermissionsDenied() {
        let action = AlertAction(style: .confirm(LocalizationConstants.goToSettings))
        let model = AlertModel(
            headline: LocalizationConstants.Errors.cameraAccessDenied,
            body: LocalizationConstants.Errors.cameraAccessDeniedMessage,
            actions: [action]
        )
        let alert = AlertView.make(with: model) { output in
            switch output.style {
            case .confirm:
                guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(settingsURL)
            case .default,
                 .dismiss:
                break
            }
        }
        alert.show()
    }

    public func promptToAcceptCameraPermissions(confirmHandler: @escaping (() -> Void)) {
        let okay = AlertAction(style: .confirm(LocalizationConstants.okString))
        let notNow = AlertAction(style: .default(LocalizationConstants.KYC.notNow))

        let model = AlertModel(
            headline: LocalizationConstants.KYC.allowCameraAccess,
            body: LocalizationConstants.KYC.enableCameraDescription,
            actions: [okay, notNow]
        )
        let alert = AlertView.make(with: model) { [weak self] output in
            switch output.style {
            case .confirm:
                self?.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionPreCameraApprove)
                confirmHandler()
            case .default,
                 .dismiss:
                self?.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionPreCameraDecline)
            }
        }
        alert.show()
    }
}
