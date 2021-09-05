// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import UIKit

protocol ContentPageControllable: ViewControllable {
    func transition(to state: ContentPage.State)
}

final class ContentPage: UIViewController, ContentPageControllable {

    enum State {
        case initial
        case render(ViewControllable)
    }

    private var state: State
    private var currentController: ViewControllable?

    init(state: State = .initial) {
        self.state = state
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        transition(to: state)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        currentController?.uiviewController.view.frame = view.bounds
    }

    func transition(to state: State) {
        guard let viewControllable = controllable(for: state) else {
            return
        }
        display(controllable: viewControllable)
        currentController = viewControllable
        self.state = state
    }

    private func display(controllable toBeDisplayed: ViewControllable) {
        if let currentControllable = currentController {
            transition(from: currentControllable.uiviewController, to: toBeDisplayed.uiviewController)
        } else {
            add(child: toBeDisplayed.uiviewController)
        }
    }

    override var childForStatusBarStyle: UIViewController? {
        children.last
    }

    override var childForStatusBarHidden: UIViewController? {
        children.last
    }

    override var childForHomeIndicatorAutoHidden: UIViewController? {
        children.last
    }

    override var childForScreenEdgesDeferringSystemGestures: UIViewController? {
        children.last
    }
}

extension ContentPage {
    func controllable(for state: State) -> ViewControllable? {
        switch state {
        case .render(let controllable):
            return controllable
        case .initial:
            return nil
        }
    }
}
