// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class SettingsSkeletonTableViewCell: UITableViewCell {

    // MARK: - Properties

    private let titleContainerView = UIView()
    private let badgeContainerView = UIView()

    // MARK: - Private Properties (ShimmeringView)

    private var badgeContainerShimmeringView: ShimmeringView!
    private var titleContainerShimmeringView: ShimmeringView!

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
        contentView.addSubview(titleContainerView)
        contentView.addSubview(badgeContainerView)
        titleContainerView.layout(edges: .top, to: contentView, offset: 8.0)
        titleContainerView.layout(edges: .leading, to: contentView, offset: 16.0)
        titleContainerView.layout(edges: .bottom, to: contentView, offset: -8.0)
        titleContainerView.layout(size: .init(width: 120.0, height: 32.0), priority: .defaultLow)
        badgeContainerView.layout(edge: .trailing, to: .trailing, of: contentView, offset: -16.0)
        badgeContainerView.layout(edge: .top, to: .top, of: contentView, offset: 8.0)
        badgeContainerView.layout(size: .init(width: 64.0, height: 32.0))
        badgeContainerShimmeringView = ShimmeringView(
            in: self,
            anchorView: badgeContainerView,
            size: .init(width: 64.0, height: 32.0),
            cornerRadius: 8.0
        )
        titleContainerShimmeringView = ShimmeringView(
            in: self,
            anchorView: titleContainerView,
            size: .init(width: 120.0, height: 32.0),
            cornerRadius: 8.0
        )
    }
}
