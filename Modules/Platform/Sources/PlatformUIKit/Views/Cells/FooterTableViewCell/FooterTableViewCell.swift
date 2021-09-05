// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class FooterTableViewCell: UITableViewCell {

    public var presenter: FooterTableViewCellPresenter! {
        didSet {
            titleLabel.content = presenter.content
        }
    }

    private let titleLabel = UILabel()

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

        contentView.addSubview(titleLabel)
        titleLabel.numberOfLines = 0
        titleLabel.layoutToSuperview(.top, offset: 16.0)
        titleLabel.layoutToSuperview(.bottom, offset: -16.0)
        titleLabel.layoutToSuperview(.leading, offset: 24.0)
        titleLabel.layoutToSuperview(.trailing, offset: -24.0)
    }
}
