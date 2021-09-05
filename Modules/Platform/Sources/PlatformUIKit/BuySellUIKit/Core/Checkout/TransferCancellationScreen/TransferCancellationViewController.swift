// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

final class TransferCancellationViewController: UIViewController {

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var noButtonView: ButtonView!
    @IBOutlet private var yesButtonView: ButtonView!

    // MARK: - Injected

    private let presenter: TransferCancellationScreenPresenter

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(presenter: TransferCancellationScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: TransferCancellationViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        noButtonView.viewModel = presenter.noButtonViewModel
        yesButtonView.viewModel = presenter.yesButtonViewModel
        titleLabel.content = presenter.titleContent
        descriptionLabel.content = presenter.descriptionContent

        presenter.dismissalRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.dismiss(animated: true, completion: nil)
            }
            .disposed(by: disposeBag)

        presenter.viewDidLoad()
    }
}
