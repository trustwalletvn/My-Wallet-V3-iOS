// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public class CardTableViewCell: UITableViewCell {

    public var viewModel: CardViewViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            titleLabel.content = viewModel.titleContent
            descriptionLabel.content = viewModel.descriptionContent
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let containerView = UIView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        contentView.addSubview(containerView)
        containerView.addSubview(stackView)
        stackView.layoutToSuperview(.leading, .top, offset: 16.0)
        stackView.layoutToSuperview(.bottom, .trailing, offset: -16.0)
        containerView.layoutToSuperview(.leading, offset: 24.0)
        containerView.layoutToSuperview(.top, offset: 16.0)
        containerView.layoutToSuperview(.bottom, offset: -16.0)
        containerView.layoutToSuperview(.trailing, offset: -24.0)

        [titleLabel, descriptionLabel].forEach { [stackView] label in
            stackView.addArrangedSubview(label)
        }

        titleLabel.numberOfLines = 0
        descriptionLabel.numberOfLines = 0

        stackView.axis = .vertical
        stackView.spacing = 4.0
        stackView.distribution = .fill

        containerView.layer.borderWidth = 1.0
        containerView.layer.cornerRadius = 4.0
        containerView.layer.borderColor = UIColor.lightBorder.cgColor
    }
}
