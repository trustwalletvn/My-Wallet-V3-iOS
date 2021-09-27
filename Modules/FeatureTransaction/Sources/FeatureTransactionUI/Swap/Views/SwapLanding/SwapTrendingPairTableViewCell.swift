// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class SwapTrendingPairTableViewCell: UITableViewCell {

    var viewModel: SwapTrendingPairViewModel! {
        didSet {
            transactionDescriptorView.viewModel = .init(
                sourceAccount: viewModel.sourceAccount,
                destinationAccount: viewModel.destinationAccount,
                assetAction: .swap
            )
            titleLabel.content = viewModel.titleLabel
            subtitleLabel.content = viewModel.subtitleLabel
        }
    }

    private let transactionDescriptorView = TransactionDescriptorView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let stackView = UIStackView()

    // MARK: - Setup

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(transactionDescriptorView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitleLabel)
        stackView.axis = .vertical
        stackView.layoutToSuperview(.top, offset: 16.0)
        stackView.layout(dimension: .height, to: 48.0, priority: .penultimateHigh)
        stackView.layoutToSuperview(.bottom, offset: -16.0)
        stackView.layoutToSuperview(.leading, offset: 24.0)

        transactionDescriptorView.layoutToSuperview(.trailing, offset: -24)
        transactionDescriptorView.layoutToSuperview(.centerY)
        transactionDescriptorView.maximizeResistanceAndHuggingPriorities()
    }
}
