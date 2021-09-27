// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import RIBs
import ToolKit

public protocol SwapRootViewControllable: ViewControllable {
    func replaceRoot(viewController: ViewControllable?)
    func replaceRoot(viewController: ViewControllable?, animated: Bool)
    func present(viewController: ViewControllable?)
    func present(viewController: ViewControllable?, animated: Bool)
}

extension SwapRootViewControllable {

    func replaceRoot(viewController: ViewControllable?) {
        replaceRoot(viewController: viewController, animated: true)
    }

    func present(viewController: ViewControllable?) {
        present(viewController: viewController, animated: true)
    }
}

final class SwapRootViewController: UINavigationController, SwapRootViewControllable {

    private let topMostViewControllerProvider: TopMostViewControllerProviding
    weak var listener: SwapRootListener?

    init(topMostViewControllerProvider: TopMostViewControllerProviding = resolve()) {
        self.topMostViewControllerProvider = topMostViewControllerProvider
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { unimplemented() }

    func replaceRoot(viewController: ViewControllable?, animated: Bool) {
        guard let viewController = viewController else {
            return
        }
        setViewControllers([viewController.uiviewController], animated: animated)
    }

    func present(viewController: ViewControllable?, animated: Bool) {
        guard let viewController = viewController else {
            return
        }
        topMostViewControllerProvider.topMostViewController?
            .present(viewController.uiviewController, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        listener?.viewDidAppear()
    }
}
