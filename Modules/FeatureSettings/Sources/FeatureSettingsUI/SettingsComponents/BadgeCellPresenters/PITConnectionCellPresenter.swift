// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import Localization
import PlatformUIKit
import RxRelay
import RxSwift

/// A `BadgeCellPresenting` class for showing the user's PIT connection status
final class PITConnectionCellPresenter: BadgeCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell

    // MARK: - Properties

    let accessibility: Accessibility = .id(AccessibilityId.ExchangeConnect.title)
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    var isLoading: Bool {
        isLoadingRelay.value
    }

    // MARK: - Private Properties

    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(pitConnectionProvider: PITConnectionStatusProviding) {
        labelContentPresenting = DefaultLabelContentPresenter(
            knownValue: LocalizationConstants.Settings.Badge.blockchainExchange,
            descriptors: .settings
        )
        badgeAssetPresenting = DefaultBadgeAssetPresenter(
            interactor: PITConnectionBadgeInteractor(provider: pitConnectionProvider)
        )

        badgeAssetPresenting.state
            .map(\.isLoading)
            .bindAndCatch(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}
