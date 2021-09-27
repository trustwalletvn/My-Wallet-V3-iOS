// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class EmailSwitchViewPresenter: SwitchViewPresenting {

    // MARK: - Types

    private typealias AccessibilityID = Accessibility.Identifier.Settings.SwitchView
    private typealias AnalyticsEvent = AnalyticsEvents.Settings

    // MARK: - Public

    let viewModel = SwitchViewModel.primary(accessibilityId: AccessibilityID.twoFactorSwitchView)

    // MARK: - Private

    private let interactor: SwitchViewInteracting
    private let disposeBag = DisposeBag()

    init(
        service: EmailNotificationSettingsServiceAPI,
        analyticsRecording: AnalyticsEventRecorderAPI = resolve()
    ) {
        interactor = EmailSwitchViewInteractor(service: service)

        viewModel.isSwitchedOnRelay
            .bindAndCatch(to: interactor.switchTriggerRelay)
            .disposed(by: disposeBag)

        viewModel.isSwitchedOnRelay
            .bind {
                analyticsRecording.record(events: [
                    AnalyticsEvent.settingsEmailNotifSwitch(value: $0),
                    AnalyticsEvents.New.Settings.notificationPreferencesUpdated(emailEnabled: $0, smsEnabled: nil)
                ])
            }
            .disposed(by: disposeBag)

        interactor.state
            .compactMap(\.value)
            .map(\.isEnabled)
            .bindAndCatch(to: viewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        interactor.state
            .compactMap(\.value)
            .map(\.isOn)
            .bindAndCatch(to: viewModel.isOnRelay)
            .disposed(by: disposeBag)
    }
}
