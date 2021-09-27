// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxRelay
import RxSwift

final class MobileCodeEntryViewController: BaseScreenViewController {

    // MARK: - Private IBOutlets

    @IBOutlet private var codeEntryTextFieldView: TextFieldView!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var changeNumberButtonView: ButtonView!
    @IBOutlet private var confirmCodeButtonView: ButtonView!
    @IBOutlet private var resendCodeButtonView: ButtonView!

    // MARK: - Private Properties

    private var keyboardInteractionController: KeyboardInteractionController!
    private let presenter: MobileCodeEntryScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(presenter: MobileCodeEntryScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: MobileCodeEntryViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: .none
        )
        titleViewStyle = presenter.titleView
        keyboardInteractionController = KeyboardInteractionController(in: self)

        codeEntryTextFieldView.setup(viewModel: presenter.codeEntryTextFieldModel, keyboardInteractionController: keyboardInteractionController)
        descriptionLabel.content = presenter.descriptionContent
        changeNumberButtonView.viewModel = presenter.changeNumberViewModel
        resendCodeButtonView.viewModel = presenter.resendCodeViewModel
        confirmCodeButtonView.viewModel = presenter.confirmViewModel
    }
}
