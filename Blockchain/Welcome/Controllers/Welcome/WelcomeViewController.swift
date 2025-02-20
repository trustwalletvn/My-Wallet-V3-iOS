// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class WelcomeViewController: BaseScreenViewController {

    // MARK: Private IBOutlets

    @IBOutlet private var welcomeLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var versionLabel: UILabel!

    @IBOutlet private var stackView: UIStackView!
    @IBOutlet private var createWalletButtonView: ButtonView!
    @IBOutlet private var loginButtonView: ButtonView!
    @IBOutlet private var recoverFundsButtonView: ButtonView!

    // MARK: Private Properties

    private let presenter: WelcomeScreenPresenter

    // MARK: - Setup

    init(presenter: WelcomeScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: String(describing: WelcomeViewController.self), bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        set(barStyle: presenter.navBarStyle)
        welcomeLabel.content = presenter.title
        descriptionLabel.attributedText = presenter.description
        versionLabel.content = presenter.version
        createWalletButtonView.viewModel = presenter.createWalletButtonViewModel
        loginButtonView.viewModel = presenter.loginButtonViewModel
        recoverFundsButtonView.viewModel = presenter.recoverFundsButtonViewModel
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
        fadeIn()
    }

    private func fadeIn() {
        let fade = { (alpha: CGFloat) -> Void in
            self.welcomeLabel.alpha = alpha
            self.descriptionLabel.alpha = alpha
            self.stackView.alpha = alpha
        }
        fade(0)
        UIView.animate(
            withDuration: 0.35,
            delay: 0,
            options: [.curveEaseOut],
            animations: { fade(1) },
            completion: nil
        )
    }
}
