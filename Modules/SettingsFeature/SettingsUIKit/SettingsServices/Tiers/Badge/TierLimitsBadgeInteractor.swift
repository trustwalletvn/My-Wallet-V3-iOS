// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import SettingsKit

final class TierLimitsBadgeInteractor: DefaultBadgeAssetInteractor {

    // MARK: - Setup

    init(limitsProviding: TierLimitsProviding) {
        super.init()
        limitsProviding.tiers
            .map { $0.interactionModel }
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}

fileprivate extension KYC.UserTiers {

    var interactionModel: BadgeAsset.State.BadgeItem.Interaction {
        // TODO: Update with correct copy + Localization
        let locked: BadgeAsset.State.BadgeItem.Interaction = .loaded(next: .locked)

        guard tiers.count > 0 else { return locked }
        guard let tier1 = tiers.filter({ $0.tier == .tier1 }).first else { return locked }
        guard let tier2 = tiers.filter({ $0.tier == .tier2 }).first else { return locked }

        let currentTier = tier2.state != .none ? tier2 : tier1

        switch currentTier.state {
        case .none:
            return .loaded(
                next: .init(
                    type: .default(accessibilitySuffix: "Verify Now"),
                    description: LocalizationConstants.KYC.accountUnverifiedBadge
                )
            )
        case .rejected:
            return .loaded(next: .init(type: .destructive, description: LocalizationConstants.KYC.verificationFailedBadge))
        case .pending:
            return .loaded(
                next: .init(
                    type: .default(accessibilitySuffix: "In Review"),
                    description: LocalizationConstants.KYC.accountInReviewBadge
                )
            )
        case .verified:
            return .loaded(next: .init(type: .verified, description: LocalizationConstants.KYC.accountApprovedBadge))
        }
    }
}

fileprivate extension BadgeAsset.Value.Interaction.BadgeItem {
    typealias Model = BadgeAsset.Value.Interaction.BadgeItem
    static let locked: Model = .init(type: .destructive, description: LocalizationConstants.Settings.Badge.Limits.failed)
}
