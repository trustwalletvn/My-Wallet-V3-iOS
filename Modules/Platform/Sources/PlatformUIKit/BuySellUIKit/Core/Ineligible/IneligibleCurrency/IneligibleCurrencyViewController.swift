// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

final class IneligibleCurrencyViewController: UIViewController {

    // MARK: - Private IBOutlets

    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var changeCurrencyButtonView: ButtonView!
    @IBOutlet private var viewHomeButtonView: ButtonView!

    // MARK: - Private Properties

    private let presenter: IneligibleCurrencyScreenPresenter
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(presenter: IneligibleCurrencyScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: IneligibleCurrencyViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.content = presenter.titleLabelContent
        descriptionLabel.content = presenter.descriptionLabelContent
        changeCurrencyButtonView.viewModel = presenter.changeCurrencyButtonViewModel
        viewHomeButtonView.viewModel = presenter.viewHomeButtonViewModel

        imageView.image = presenter.thumbnail

        presenter.dismissalRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.dismiss(animated: true) {
                    self.presenter.dismiss()
                }
            }
            .disposed(by: disposeBag)

        presenter.restartRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in
                self.dismiss(animated: true) {
                    self.presenter.changeCurrency()
                }
            }
            .disposed(by: disposeBag)
    }
}
