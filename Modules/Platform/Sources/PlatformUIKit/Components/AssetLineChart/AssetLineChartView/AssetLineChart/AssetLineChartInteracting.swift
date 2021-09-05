// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxSwift

public protocol AssetLineChartInteracting: AnyObject {

    var priceWindowRelay: PublishRelay<PriceWindow> { get }

    var state: Observable<AssetLineChart.State.Interaction> { get }
}
