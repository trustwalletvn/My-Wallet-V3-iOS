// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class RecoveryPhraseViewController: BaseScreenViewController {

    // MARK: Private Properties

    private let presenter: RecoveryPhraseScreenPresenter

    // MARK: Private IBOutlets

    @IBOutlet private var subtitleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var recoveryPhraseView: RecoveryPhraseView!
    @IBOutlet private var nextButtonView: ButtonView!

    // MARK: - Setup

    init(presenter: RecoveryPhraseScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: RecoveryPhraseViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        subtitleLabel.content = presenter.subtitle
        descriptionLabel.content = presenter.description
        recoveryPhraseView.viewModel = presenter.recoveryViewModel
        nextButtonView.viewModel = presenter.nextViewModel
    }

    private func setupNavigationBar() {
        titleViewStyle = presenter.titleView
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
    }

    // MARK: - Navigation

    override func navigationBarLeadingButtonPressed() {
        presenter.navigationBarLeadingButtonTapped()
    }
}
