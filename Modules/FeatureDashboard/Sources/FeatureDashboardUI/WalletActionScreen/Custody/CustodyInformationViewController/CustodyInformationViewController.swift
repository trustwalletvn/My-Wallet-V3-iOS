// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class CustodyInformationViewController: BaseScreenViewController {

    // MARK: Private Properties

    private let presenter: CustodyInformationScreenPresenter

    // MARK: Private IBOutlets

    @IBOutlet private var okButtonView: ButtonView!
    @IBOutlet private var backgroundImageView: UIImageView!
    @IBOutlet private var walletIllustrationImageView: UIImageView!
    @IBOutlet private var primaryDescriptionLabel: UILabel!
    @IBOutlet private var secondaryDescriptionLabel: UILabel!

    // MARK: - Setup

    init(presenter: CustodyInformationScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: CustodyInformationViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        okButtonView.viewModel = presenter.okButtonViewModel
        primaryDescriptionLabel.content = presenter.description
        secondaryDescriptionLabel.content = presenter.subDescription

        titleViewStyle = presenter.titleView
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )

        applyAnimation()
    }

    private func applyAnimation() {
        UIView.animate(
            withDuration: 1.0,
            delay: 0,
            options: [.repeat, .autoreverse, .curveEaseInOut],
            animations: {
                self.walletIllustrationImageView.transform = .init(translationX: 0.0, y: 7.0)
            },
            completion: nil
        )
    }

    override func navigationBarTrailingButtonPressed() {
        presenter.navigationBarTrailingButtonTapped()
    }
}
