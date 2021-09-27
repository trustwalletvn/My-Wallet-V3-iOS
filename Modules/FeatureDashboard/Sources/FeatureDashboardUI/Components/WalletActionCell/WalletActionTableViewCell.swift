// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

final class WalletActionTableViewCell: UITableViewCell {

    // MARK: - Properties

    var presenter: WalletActionCellPresenter! {
        didSet {
            badgeImageView.viewModel = presenter.badgeImageViewModel
            titleLabel.content = presenter.titleLabelContent
            descriptionLabel.content = presenter.descriptionLabelContent
        }
    }

    // MARK: - Private Properties

    private let badgeImageView = BadgeImageView()
    private let stackView = UIStackView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()

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

        contentView.addSubview(badgeImageView)
        contentView.addSubview(stackView)
        stackView.axis = .vertical
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)

        badgeImageView.layoutToSuperview(.leading, offset: Spacing.outer)
        badgeImageView.layout(size: .init(edge: Sizing.badge))
        badgeImageView.layout(edges: .centerY, to: stackView)
        stackView.layout(to: .top, of: contentView, offset: Spacing.inner)
        stackView.layout(edges: .trailing, to: contentView, offset: -Spacing.inner)
        stackView.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Spacing.inner)
        stackView.layout(edges: .centerY, to: contentView)
    }
}
