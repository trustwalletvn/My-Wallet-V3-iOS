// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

final class ActivitySkeletonTableViewCell: UITableViewCell {

    // MARK: - Private IBOutlets

    @IBOutlet private var badgeContainerView: UIView!
    @IBOutlet private var titleContainerView: UIView!
    @IBOutlet private var subtitleContainerView: UIView!

    // MARK: - Private Properties (ShimmeringView)

    private var badgeContainerShimmeringView: ShimmeringView!
    private var titleContainerShimmeringView: ShimmeringView!
    private var subtitleContainerShimmeringView: ShimmeringView!

    // MARK: - Setup

    override func awakeFromNib() {
        super.awakeFromNib()
        badgeContainerShimmeringView = ShimmeringView(
            in: self,
            centeredIn: badgeContainerView,
            size: badgeContainerView.bounds.size,
            cornerRadius: 16.0
        )
        titleContainerShimmeringView = ShimmeringView(
            in: self,
            centeredIn: titleContainerView,
            size: titleContainerView.bounds.size
        )
        subtitleContainerShimmeringView = ShimmeringView(
            in: self,
            centeredIn: subtitleContainerView,
            size: subtitleContainerView.bounds.size
        )
    }
}
