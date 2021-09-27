// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift

/// The interaction protocol for the balance
/// and historical prices cell on the dashboard
protocol HistoricalAmountInteracting {
    /// The historical prices and balance
    /// calculation state
    var state: Observable<DashboardAsset.State.AssetPrice.Interaction> { get }
}
