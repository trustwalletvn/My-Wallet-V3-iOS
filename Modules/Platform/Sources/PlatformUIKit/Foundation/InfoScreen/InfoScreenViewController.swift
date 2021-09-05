// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class InfoScreenViewController: BaseScreenViewController {

    // MARK: - IBOutlets

    @IBOutlet private var thumbImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var disclaimerTextView: InteractableTextView!
    @IBOutlet private var buttonView: ButtonView!

    // MARK: - Injected

    private let presenter: InfoScreenPresenter

    // MARK: - Lifecycle

    public init(presenter: InfoScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: InfoScreenViewController.objectName, bundle: .module)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        set(
            barStyle: .darkContent(background: .clear),
            leadingButtonStyle: .close
        )
        thumbImageView.set(presenter.imageViewContent)
        titleLabel.content = presenter.titleLabelContent
        descriptionLabel.content = presenter.descriptionLabelContent
        disclaimerTextView.viewModel = presenter.disclaimerViewModel
        buttonView.viewModel = presenter.buttonViewModel
    }
}
