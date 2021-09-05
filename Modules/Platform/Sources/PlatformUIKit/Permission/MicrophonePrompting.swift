// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Localization
import PlatformKit
import ToolKit

public protocol MicrophonePrompting: AnyObject {
    var permissionsRequestor: PermissionsRequestor { get set }
    var microphonePromptingDelegate: MicrophonePromptingDelegate? { get set }

    func checkMicrophonePermissions()
    func willUseMicrophone()
}

extension MicrophonePrompting {
    public func checkMicrophonePermissions() {
        permissionsRequestor.requestPermissions([.microphone]) { [weak self] in
            guard let self = self else { return }
            self.microphonePromptingDelegate?.onMicrophonePromptingComplete()
        }
    }

    public func willUseMicrophone() {
        if PermissionsRequestor.shouldDisplayMicrophonePermissionsRequest() {
            microphonePromptingDelegate?.promptToAcceptMicrophonePermissions(confirmHandler: {
                self.checkMicrophonePermissions()
            })
            return
        } else {
            microphonePromptingDelegate?.onMicrophonePromptingComplete()
        }
    }
}

public protocol MicrophonePromptingDelegate: AnyObject {
    var analyticsRecorder: AnalyticsEventRecorderAPI { get }

    func onMicrophonePromptingComplete()
    func promptToAcceptMicrophonePermissions(confirmHandler: @escaping (() -> Void))
}

extension MicrophonePromptingDelegate {
    public func promptToAcceptMicrophonePermissions(confirmHandler: @escaping (() -> Void)) {
        let okay = AlertAction(style: .confirm(LocalizationConstants.okString))
        let notNow = AlertAction(style: .default(LocalizationConstants.KYC.notNow))

        let model = AlertModel(
            headline: LocalizationConstants.KYC.allowMicrophoneAccess,
            body: LocalizationConstants.KYC.enableMicrophoneDescription,
            actions: [okay, notNow]
        )
        let alert = AlertView.make(with: model) { output in
            switch output.style {
            case .confirm,
                 .default:
                self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionPreMicApprove)
                confirmHandler()
            case .dismiss:
                self.analyticsRecorder.record(event: AnalyticsEvents.Permission.permissionPreMicDecline)
            }
        }
        alert.show()
    }
}
