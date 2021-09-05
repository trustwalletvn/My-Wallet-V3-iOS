// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public protocol SwitchViewInteracting {
    var state: Observable<LoadingState<SwitchInteractionAsset>> { get }
    var switchTriggerRelay: PublishRelay<Bool> { get }
}
