//
//  KYCTiersPageModel.swift
//  Blockchain
//
//  Created by AlexM on 12/11/18.
//  Copyright © 2018 Blockchain Luxembourg S.A. All rights reserved.
//

import DIKit
import Localization
import PlatformKit
import RxSwift
import ToolKit

public struct KYCTiersPageModel {
    let header: KYCTiersHeaderViewModel
    let cells: [KYCTierCellModel]
}

extension KYCTiersPageModel {
    var disclaimer: String? {
        guard let tierTwo = cells.filter({ $0.tier == .tier2 }).first else { return nil }
        guard tierTwo.status != .rejected else { return nil }
        return LocalizationConstants.KYC.completingTierTwoAutoEligible
    }

    func trackPresentation(analytics: AnalyticsServiceAPI) {
        let metadata = cells.map({ ($0.tier, $0.status) })
        guard let tier1 = metadata.filter({ $0.0 == .tier1 }).first else { return }
        guard let tier2 = metadata.filter({ $0.0 == .tier2 }).first else { return }
        let tierOneStatus = tier1.1
        let tierTwoStatus = tier2.1
        switch (tierOneStatus, tierTwoStatus) {
        case (.none, .none):
            analytics.trackEvent(title: KYC.Tier.lockedAnalyticsKey)
        case (.approved, .none):
            analytics.trackEvent(title: tier1.0.completionAnalyticsKey)
        case (_, .inReview),
             (_, .approved):
            analytics.trackEvent(title: tier2.0.completionAnalyticsKey)
        default:
            break
        }
    }

    public static func make(tiers: KYC.UserTiers, maxTradableToday: FiatValue, suppressCTA: Bool) -> KYCTiersPageModel {
        let header = KYCTiersHeaderViewModel.make(
            with: tiers,
            availableFunds: maxTradableToday.toDisplayString(includeSymbol: true),
            suppressDismissCTA: suppressCTA
        )
        let models = tiers.tiers
            .filter { $0.tier != .tier0 }
            .map { KYCTierCellModel.model(from: $0) }
            .compactMap { $0 }
        return KYCTiersPageModel(header: header, cells: models)
    }

}
