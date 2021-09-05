// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

extension SharedSequenceConvertibleType where Self.SharingStrategy == RxCocoa.SignalSharingStrategy {
    public func emit<A: AnyObject>(
        weak object: A,
        onNext: ((A, Element) -> Void)? = nil,
        onCompleted: ((A) -> Void)? = nil,
        onDisposed: ((A) -> Void)? = nil
    ) -> Disposable {
        emit(
            onNext: { [weak object] element in
                guard let object = object else { return }
                onNext?(object, element)
            },
            onCompleted: { [weak object] in
                guard let object = object else { return }
                onCompleted?(object)
            },
            onDisposed: { [weak object] in
                guard let object = object else { return }
                onDisposed?(object)
            }
        )
    }

    public func emit<A: AnyObject>(
        weak object: A,
        onNext: ((A, Element) -> Void)? = nil
    ) -> Disposable {
        emit(
            onNext: { [weak object] element in
                guard let object = object else { return }
                onNext?(object, element)
            }
        )
    }

    public func emit<A: AnyObject>(
        weak object: A,
        onNext: ((A) -> Void)? = nil
    ) -> Disposable {
        emit(
            onNext: { [weak object] _ in
                guard let object = object else { return }
                onNext?(object)
            }
        )
    }
}
