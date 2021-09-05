// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AssetLineChartUserInteracting {
    var state: Observable<AssetLineChartInteractionState> { get }
}
