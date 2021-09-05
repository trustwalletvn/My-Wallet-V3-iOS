// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts

public final class AssetLineChartPresenterContainer {
    let priceViewPresenter: AssetPriceViewPresenter
    let lineChartPresenter: AssetLineChartPresenter
    let lineChartView: LineChartView

    public init(
        priceViewPresenter: AssetPriceViewPresenter,
        lineChartPresenter: AssetLineChartPresenter,
        lineChartView: LineChartView
    ) {
        self.priceViewPresenter = priceViewPresenter
        self.lineChartPresenter = lineChartPresenter
        self.lineChartView = lineChartView
    }
}
