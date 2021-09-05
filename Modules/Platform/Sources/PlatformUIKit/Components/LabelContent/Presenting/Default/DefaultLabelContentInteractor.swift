// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public final class DefaultLabelContentInteractor: LabelContentInteracting {

    // MARK: - Types

    public typealias InteractionState = LabelContent.State.Interaction

    // MARK: - LabelContentInteracting

    public let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    public var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    public init(knownValue: String) {
        stateRelay.accept(.loaded(next: .init(text: knownValue)))
    }

    public init() {}
}
