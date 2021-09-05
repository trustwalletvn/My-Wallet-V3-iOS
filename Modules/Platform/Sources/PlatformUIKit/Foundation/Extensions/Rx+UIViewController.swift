// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

extension Reactive where Base: UIViewController {

    /// Reactive wrapper for `UIViewController.viewDidLoad`
    public var viewDidLoad: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewDidLoad))
            .map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewWillAppear`
    public var viewWillAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewWillAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewDidAppear`
    public var viewDidAppear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewDidAppear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewWillDisappear`
    public var viewWillDisappear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewWillDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewDidDisappear`
    public var viewDidDisappear: ControlEvent<Bool> {
        let source = methodInvoked(#selector(Base.viewDidDisappear)).map { $0.first as? Bool ?? false }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewWillLayoutSubviews`
    public var viewWillLayoutSubviews: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewWillLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.viewDidLayoutSubviews`
    public var viewDidLayoutSubviews: ControlEvent<Void> {
        let source = methodInvoked(#selector(Base.viewDidLayoutSubviews)).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.willMove`
    public var willMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = methodInvoked(#selector(Base.willMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for `UIViewController.didMove`
    public var didMoveToParentViewController: ControlEvent<UIViewController?> {
        let source = methodInvoked(#selector(Base.didMove)).map { $0.first as? UIViewController }
        return ControlEvent(events: source)
    }

    /// Observable stream that streams if the view controller is visible or not
    public var isVisible: Observable<Bool> {
        let viewDidAppearObservable = base.rx.viewDidAppear.map { _ in true }
        let viewWillDisappearObservable = base.rx.viewWillDisappear.map { _ in false }
        return Observable<Bool>.merge(viewDidAppearObservable, viewWillDisappearObservable)
            .share(replay: 1, scope: .whileConnected)
    }

    /// Reactive wrapper for `UIViewController.viewWillAppear`
    ///
    ///  **Note** this will be called once, hence the `firstTime` prefix
    public var firstTimeViewWillAppear: Observable<Void> {
        sentMessage(#selector(Base.viewWillAppear))
            .map { _ in () }
            .take(1)
            .share(replay: 1, scope: .whileConnected)
    }

    /// Reactive wrapper for `UIViewController.viewDidAppear` but called once
    ///
    ///  **Note** this will be called once, hence the `firstTime` prefix
    public var firstTimeViewDidAppear: Observable<Void> {
        sentMessage(#selector(Base.viewDidAppear))
            .map { _ in () }
            .take(1)
            .share(replay: 1, scope: .whileConnected)
    }
}
