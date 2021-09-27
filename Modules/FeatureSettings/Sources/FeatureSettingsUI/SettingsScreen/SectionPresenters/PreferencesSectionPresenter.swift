// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class PreferencesSectionPresenter: SettingsSectionPresenting {

    // MARK: - SettingsSectionPresenting

    let sectionType: SettingsSectionType = .preferences

    var state: Observable<SettingsSectionLoadingState> {
        .just(
            .loaded(next:
                .some(
                    .init(
                        sectionType: sectionType,
                        items: [
                            .init(cellType: .switch(.emailNotifications, emailNotificationsCellPresenter)),
                            .init(cellType: .badge(.currencyPreference, preferredCurrencyCellPresenter))
                        ]
                    )
                )
            )
        )
    }

    private let emailNotificationsCellPresenter: EmailNotificationsSwitchCellPresenter
    private let preferredCurrencyCellPresenter: PreferredCurrencyCellPresenter

    init(
        emailNotificationService: EmailNotificationSettingsServiceAPI,
        preferredCurrencyBadgeInteractor: PreferredCurrencyBadgeInteractor
    ) {
        emailNotificationsCellPresenter = .init(service: emailNotificationService)
        preferredCurrencyCellPresenter = .init(interactor: preferredCurrencyBadgeInteractor)
    }
}
