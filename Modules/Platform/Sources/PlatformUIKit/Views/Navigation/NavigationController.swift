// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class NavigationController: UINavigationController, UIGestureRecognizerDelegate {

    public init() {
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        setup()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        interactivePopGestureRecognizer?.delegate = self
    }
}
