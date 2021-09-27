// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import PlatformUIKit
import RxRelay
import RxSwift

/// A `BadgeCellPresenting` class for showing the user's Swap Limits
final class TierLimitsCellPresenter: BadgeCellPresenting {

    private typealias AccessibilityId = Accessibility.Identifier.Settings.SettingsCell

    // MARK: - Properties

    let accessibility: Accessibility = .id(AccessibilityId.AccountLimits.title)
    let labelContentPresenting: LabelContentPresenting
    let badgeAssetPresenting: BadgeAssetPresenting
    var isLoading: Bool {
        isLoadingRelay.value
    }

    // MARK: - Private Properties

    private let isLoadingRelay = BehaviorRelay<Bool>(value: true)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(tiersProviding: TierLimitsProviding) {
        labelContentPresenting = TierLimitsLabelContentPresenter(provider: tiersProviding, descriptors: .settings)
        badgeAssetPresenting = DefaultBadgeAssetPresenter(
            interactor: TierLimitsBadgeInteractor(limitsProviding: tiersProviding)
        )
        badgeAssetPresenting.state
            .map(\.isLoading)
            .bindAndCatch(to: isLoadingRelay)
            .disposed(by: disposeBag)
    }
}
