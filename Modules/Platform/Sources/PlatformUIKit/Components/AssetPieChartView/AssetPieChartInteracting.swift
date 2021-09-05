// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AssetPieChartInteracting: AnyObject {
    var state: Observable<AssetPieChart.State.Interaction> { get }

    func refresh()
}
