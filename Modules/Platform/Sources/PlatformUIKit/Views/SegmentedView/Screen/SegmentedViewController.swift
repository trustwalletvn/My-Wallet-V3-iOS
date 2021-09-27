// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import ToolKit

/// `SegmentedViewController` is a easy to used ViewController containing a `SegmentedView`
/// as `titleView` of it's `navigationItem`.
public final class SegmentedViewController: BaseScreenViewController {

    private lazy var segmentedView = SegmentedView()
    private let presenter: SegmentedViewScreenPresenting
    private let rootViewController: SegmentedTabViewController
    private let disposeBag = DisposeBag()

    required init?(coder: NSCoder) { unimplemented() }
    public init(presenter: SegmentedViewScreenPresenting) {
        self.presenter = presenter
        rootViewController = SegmentedTabViewController(items: presenter.items)
        super.init(nibName: nil, bundle: nil)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        segmentedView.viewModel = presenter.segmentedViewModel
        add(child: rootViewController)
        presenter.itemIndexSelected
            .compactMap { $0 }
            .bindAndCatch(to: rootViewController.itemIndexSelectedRelay)
            .disposed(by: disposeBag)
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
        setupSegmentedView()
    }

    private func setupSegmentedView() {
        let rootView = rootViewController.view!
        switch presenter.segmentedViewLocation {
        case .navBar:
            segmentedView.layout(dimension: .width, to: 196)
            titleViewStyle = .view(value: segmentedView)
            rootView.layoutToSuperview(axis: .horizontal)
            rootView.layoutToSuperview(axis: .vertical)
        case .top(let titleViewStyle):
            self.titleViewStyle = titleViewStyle
            view.addSubview(segmentedView)
            rootView.layoutToSuperview(.leading, .bottom, .trailing)
            rootView.layoutToSuperview(.top, relation: .equal, usesSafeAreaLayoutGuide: false, offset: 64)
            segmentedView.layoutToSuperview(axis: .horizontal, offset: 24)
            segmentedView.layout(dimension: .height, to: 36)
            segmentedView.layout(edge: .bottom, to: .top, of: rootView)
        }
    }

    override public func navigationBarLeadingButtonPressed() {
        presenter.leadingButtonTapRelay.accept(())
    }

    override public func navigationBarTrailingButtonPressed() {
        presenter.trailingButtonTapRelay.accept(())
    }
}
