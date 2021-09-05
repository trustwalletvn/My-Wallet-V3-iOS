// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol AssetLineChartInteractionPresenting {
    var selectedIndex: Observable<Int> { get }
}
