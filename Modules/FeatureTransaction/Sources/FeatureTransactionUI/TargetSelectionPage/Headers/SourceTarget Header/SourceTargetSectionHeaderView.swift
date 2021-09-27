// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class SourceTargetSectionHeaderView: UIView {
    static let defaultHeight: CGFloat = 64
    private let titleLabel = UILabel()
    private let separator = UIView()

    var model: SourceTargetSectionHeaderModel! {
        didSet {
            titleLabel.content = model?.sectionTitleLabel ?? .empty
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(titleLabel)
        addSubview(separator)

        // MARK: Subtitle Label

        titleLabel.layoutToSuperview(.leading, offset: 24)
        titleLabel.layoutToSuperview(.bottom, offset: -4)

        // MARK: Separator

        separator.backgroundColor = .lightBorder
        separator.layout(dimension: .height, to: 1)
        separator.layout(edge: .leading, to: .trailing, of: titleLabel, offset: 8)
        separator.layoutToSuperview(.trailing)
        separator.layout(edge: .bottom, to: .lastBaseline, of: titleLabel)

        // MARK: Setup

        clipsToBounds = true
        titleLabel.numberOfLines = 1
    }
}
