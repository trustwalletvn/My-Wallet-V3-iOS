// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Represents a labeled-button embedded inside a `UICollectionViewCell`
final class LabeledButtonCollectionViewCell<ViewModel: LabeledButtonViewModelAPI>: UICollectionViewCell {

    // MARK: - Properties

    var viewModel: ViewModel! {
        didSet {
            labeledButtonView.viewModel = viewModel
        }
    }

    private let labeledButtonView = LabeledButtonView<ViewModel>()

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(labeledButtonView)
        labeledButtonView.fillSuperview()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}
