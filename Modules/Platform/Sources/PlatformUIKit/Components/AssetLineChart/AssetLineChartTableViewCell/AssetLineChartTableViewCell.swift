// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class AssetLineChartTableViewCell: UITableViewCell {

    public var presenter: AssetLineChartTableViewCellPresenter! {
        didSet {
            assetLineChartView.presenter = presenter?.presenterContainer
            segmentedView.viewModel = presenter?.priceWindowPresenter.segmentedViewModel
        }
    }

    @IBOutlet private var assetLineChartView: AssetLineChartView!
    @IBOutlet private var segmentedView: SegmentedView!

    // MARK: - Lifecycle

    override public func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
