// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public protocol LabelContentPresenting {
    var interactor: LabelContentInteracting { get }

    var stateRelay: BehaviorRelay<LabelContent.State.Presentation> { get }
    var state: Observable<LabelContent.State.Presentation> { get }
}
