// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformUIKit
import ToolKit
import UIKit

public final class DashboardScreenBuilder {

    private let drawerRouter: DrawerRouting
    private let fiatBalanceCellProvider: FiatBalanceCellProviding
    private let internalFeatureFlagService: InternalFeatureFlagServiceAPI

    public init(
        drawerRouter: DrawerRouting = resolve(),
        fiatBalanceCellProvider: FiatBalanceCellProviding = resolve(),
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve()
    ) {
        self.drawerRouter = drawerRouter
        self.fiatBalanceCellProvider = fiatBalanceCellProvider
        self.internalFeatureFlagService = internalFeatureFlagService
    }

    public func build() -> UIViewController {
        switch internalFeatureFlagService.isEnabled(.splitDashboard) {
        case true:
            return SegmentedViewController(
                presenter: DashboardSegmentedViewScreenPresenter(
                    drawerRouter: drawerRouter,
                    fiatBalanceCellProvider: fiatBalanceCellProvider,
                    dashboardScreenPresenter: .init()
                )
            )
        case false:
            return PortfolioViewController(
                fiatBalanceCellProvider: fiatBalanceCellProvider,
                presenter: .init()
            )
        }
    }
}
