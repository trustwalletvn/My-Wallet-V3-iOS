// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class AddBankTableViewCell: UITableViewCell {

    private let iconAddImageView = UIImageView()
    private let badgeImageView = BadgeImageView()
    private let titleLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        iconAddImageView.image = UIImage(named: "Icon-Add-Circle")
        titleLabel.textColor = .titleText

        contentView.addSubview(badgeImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(iconAddImageView)

        badgeImageView.layoutToSuperview(.centerY)
        badgeImageView.layout(size: CGSize(width: 32, height: 20))
        badgeImageView.layoutToSuperview(.leading, offset: Spacing.outer)

        titleLabel.layoutToSuperview(.centerY)
        titleLabel.layoutToSuperview(.top, offset: Spacing.inner)
        titleLabel.layoutToSuperview(.bottom, offset: -Spacing.inner)
        titleLabel.layout(edge: .leading, to: .trailing, of: badgeImageView, offset: Spacing.inner)
        titleLabel.layoutToSuperview(.trailing, offset: -Spacing.outer)

        iconAddImageView.layout(size: CGSize(width: 22, height: 22))
        iconAddImageView.layoutToSuperview(.centerY)
        iconAddImageView.layoutToSuperview(.trailing, offset: -Spacing.outer)
    }

    func configure(viewModel: AddBankCellModel) {
        badgeImageView.viewModel = viewModel.badgeImageViewModel
        titleLabel.content = viewModel.titleLabelContent
    }
}
