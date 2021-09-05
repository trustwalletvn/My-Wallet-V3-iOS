// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxCocoa
import RxSwift

class MockReactiveWallet: ReactiveWalletAPI {

    let mockState = PublishSubject<WalletSetup.State>()

    var waitUntilInitializedSingle: Single<Void> {
        mockState.filter { $0 == .initialized }.take(1).asSingle().mapToVoid()
    }

    var waitUntilInitialized: Observable<Void> {
        mockState.filter { $0 == .initialized }.mapToVoid()
    }

    var initializationState: Single<WalletSetup.State> {
        mockState.asSingle()
    }

    var waitUntilInitializedSinglePublisher: AnyPublisher<Void, Never> {
        waitUntilInitializedSingle.asPublisher().ignoreFailure()
    }

    var waitUntilInitializedStreamPublisher: AnyPublisher<Void, Never> {
        waitUntilInitialized.asPublisher().ignoreFailure()
    }

    var initializationStatePublisher: AnyPublisher<WalletSetup.State, Never> {
        initializationState.asPublisher().ignoreFailure()
    }

    init() {}
}
