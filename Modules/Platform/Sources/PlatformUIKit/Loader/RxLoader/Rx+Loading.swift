// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

extension PrimitiveSequence where Trait == SingleTrait {

    /// Shows the loader
    public func show(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Single<Element> {
        self.do(onSuccess: { _ in
            loader.show(with: style, text: text)
        })
    }

    /// Hides the loader
    public func hide(loader: LoadingViewPresenting) -> Single<Element> {
        self.do(onSuccess: { _ in
            loader.hide()
        })
    }

    /// Show the loader and returns `Element`
    public func showOnSubscription(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Single<Element> {
        self.do(onSubscribe: {
            loader.show(with: text)
        })
    }

    /// Hides the loader and returns `Element`
    public func hideOnDisposal(loader: LoadingViewPresenting) -> Single<Element> {
        self.do(onDispose: {
            loader.hide()
        })
    }

    /// Shows and hides the loader
    public func handleLoaderForLifecycle(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Single<Element> {
        self.do(onSubscribe: {
            loader.show(with: style, text: text)
        }, onDispose: {
            loader.hide()
        })
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
extension ObservableType {

    /// Show the loader and returns `Element`
    public func show(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Observable<Element> {
        self.do(onNext: { _ in
            loader.show(with: style, text: text)
        })
    }

    /// Hides the loader and returns `Element`
    public func hide(loader: LoadingViewPresenting) -> Observable<Element> {
        self.do(onNext: { _ in
            loader.hide()
        })
    }
}

/// Extension for `ObservableType` that enables the loader to take part in a chain of observables
extension ObservableType {

    /// Shows and hides the loader
    public func handleLoaderForLifecycle(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Observable<Element> {
        self.do(onSubscribe: {
            loader.show(with: style, text: text)
        }, onDispose: {
            loader.hide()
        })
    }

    /// Shows the loader upon subscription
    public func showLoaderOnSubscription(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Observable<Element> {
        self.do(onSubscribe: {
            loader.show(with: style, text: text)
        })
    }

    /// Hides the loader upon disposal
    public func hideLoaderOnDisposal(loader: LoadingViewPresenting) -> Observable<Element> {
        self.do(onDispose: {
            loader.hide()
        })
    }
}

/// Extension for any component that inherits `ReactiveLoaderPresenting`.
/// Enables Rx for displaying and hiding the loader
extension Reactive where Base: ReactiveLoaderPresenting {

    /// Show the loader and returns `Element`
    public func show(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Completable {
        Completable.create { completable -> Disposable in
            loader.show(with: style, text: text)
            completable(.completed)
            return Disposables.create()
        }
    }

    /// Show the loader and returns `Element`
    public func hide(loader: LoadingViewPresenting) -> Completable {
        Completable.create { completable -> Disposable in
            loader.hide()
            completable(.completed)
            return Disposables.create()
        }
    }
}

extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {

    /// Shows the loader
    public func show(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Completable {
        self.do(onCompleted: {
            loader.show(with: style, text: text)
        })
    }

    /// Hides the loader
    public func hide(loader: LoadingViewPresenting) -> Completable {
        self.do(onCompleted: {
            loader.hide()
        })
    }

    /// Show the loader and returns `Element`
    public func showOnSubscription(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Completable {
        self.do(onSubscribe: {
            loader.show(with: text)
        })
    }

    /// Hides the loader and returns `Element`
    public func hideOnDisposal(loader: LoadingViewPresenting) -> Completable {
        self.do(onDispose: {
            loader.hide()
        })
    }

    /// Shows and hides the loader
    public func handleLoaderForLifecycle(
        loader: LoadingViewPresenting,
        style: LoadingViewPresenter.LoadingViewStyle = .activityIndicator,
        text: String? = nil
    ) -> Completable {
        self.do(onSubscribe: {
            loader.show(with: style, text: text)
        }, onDispose: {
            loader.hide()
        })
    }
}
