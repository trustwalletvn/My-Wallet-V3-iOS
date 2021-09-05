// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol BadgeAssetInteracting {
    var state: Observable<BadgeAsset.State.BadgeItem.Interaction> { get }
    var stateRelay: BehaviorRelay<BadgeAsset.State.BadgeItem.Interaction> { get }
}
