// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol BadgeAssetPresenting {
    var state: Observable<BadgeAsset.State.BadgeItem.Presentation> { get }
}
