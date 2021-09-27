// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class ActivityMessageView: UIView {

    var viewModel: ActivityMessageViewModel! {
        didSet {
            qrImageView.image = viewModel.image
            titleLabel.content = viewModel.titleLabelContent
            descriptionLabel.content = viewModel.descriptionLabelContent
            cryptoValueLabel.content = viewModel.cryptoAmountLabelContent
            sharedWithLabel.content = viewModel.sharedWithLabelContent
            badgeImageView.viewModel = viewModel.badgeImageViewModel
        }
    }

    // MARK: - Private Properties (UIStackView)

    private let stackView = UIStackView()
    private let summaryStackView = UIStackView()
    private let descriptorsStackView = UIStackView()
    private let sharedWithStackView = UIStackView()

    private let containerView = UIView()
    private let badgeImageView = BadgeImageView()
    private let imageContainerView = UIView()

    // MARK: - Private Properties (UIImageView)

    private let qrImageView = UIImageView()
    private let logoImageView = UIImageView()

    // MARK: - Private Properties (UILabel)

    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let cryptoValueLabel = UILabel()
    private let sharedWithLabel = UILabel()

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        backgroundColor = .lightGray
        addSubview(containerView)

        // MARK: - Container View

        containerView.backgroundColor = .white
        containerView.layer.shadowColor = UIColor.securePinGrey.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: Spacing.standard)
        containerView.layer.shadowOpacity = 1
        containerView.layer.shadowRadius = 8.0
        containerView.layer.cornerRadius = 16.0
        containerView.clipsToBounds = false

        containerView.layoutToSuperview(axis: .horizontal, offset: Spacing.inner)
        containerView.layoutToSuperview(axis: .vertical, offset: Spacing.inner)

        containerView.addSubview(stackView)

        // MARK: - Stack View

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing

        stackView.layout(edges: .top, .leading, to: containerView, offset: Spacing.standard)
        stackView.layout(edges: .bottom, .trailing, to: containerView, offset: -Spacing.standard)

        stackView.addArrangedSubview(summaryStackView)
        stackView.addArrangedSubview(imageContainerView)
        stackView.addArrangedSubview(sharedWithStackView)

        // MARK: - Summary Stack View

        summaryStackView.axis = .horizontal
        summaryStackView.alignment = .leading
        summaryStackView.spacing = Spacing.inner

        summaryStackView.addArrangedSubview(badgeImageView)
        summaryStackView.addArrangedSubview(descriptorsStackView)

        // MARK: - Badge Image View

        badgeImageView.layout(size: .init(edge: Sizing.badge))

        // MARK: - Descriptors Stack View

        descriptorsStackView.axis = .vertical
        descriptorsStackView.alignment = .leading

        descriptorsStackView.addArrangedSubview(titleLabel)
        descriptorsStackView.addArrangedSubview(descriptionLabel)
        descriptorsStackView.addArrangedSubview(cryptoValueLabel)

        // MARK: - Image Container View

        imageContainerView.layer.shadowColor = UIColor.securePinGrey.cgColor
        imageContainerView.layer.shadowOffset = CGSize(width: 0, height: Spacing.standard)
        imageContainerView.layer.shadowOpacity = 0.5
        imageContainerView.layer.shadowRadius = 8.0
        imageContainerView.clipsToBounds = false

        imageContainerView.addSubview(qrImageView)

        // MARK: - QR Image View

        qrImageView.contentMode = .scaleAspectFit
        qrImageView.verticalContentCompressionResistancePriority = .defaultLow

        qrImageView.layout(edges: .top, .leading, to: imageContainerView, offset: Spacing.standard)
        qrImageView.layout(edges: .bottom, .trailing, to: imageContainerView, offset: -Spacing.standard)

        // MARK: - Shared With Stack View

        sharedWithStackView.axis = .horizontal
        sharedWithStackView.alignment = .trailing
        sharedWithStackView.spacing = Spacing.interItem

        sharedWithStackView.addArrangedSubview(sharedWithLabel)
        sharedWithStackView.addArrangedSubview(logoImageView)

        // MARK: - Logo Image View

        logoImageView.image = UIImage(named: "logo_small")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.layout(size: .init(edge: 16.0))
    }
}
