// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

extension CompositeDisposable {
    @discardableResult
    public func insertWithDiscardableResult(_ disposable: Disposable) -> CompositeDisposable.DisposeKey? {
        insert(disposable)
    }
}

extension ObservableType {
    public func optional() -> Observable<Element?> {
        map { element -> Element? in
            element
        }
    }

    public func mapToVoid() -> Observable<Void> {
        map { _ in () }
    }
}

extension PrimitiveSequenceType where Trait == SingleTrait {
    public func optional() -> Single<Element?> {
        map { element -> Element? in
            element
        }
    }

    public func mapToVoid() -> Single<Void> {
        map { _ in () }
    }
}

extension Publisher {

    public func asSingle() -> Single<Output> {
        asObservable()
            .take(1)
            .asSingle()
    }
}
