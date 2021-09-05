// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public protocol LabelContentInteracting {
    var stateRelay: BehaviorRelay<LabelContent.State.Interaction> { get }
    var state: Observable<LabelContent.State.Interaction> { get }
}
