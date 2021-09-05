// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

/// An Rx driven line-chart view
public final class AssetLineChartView: UIView {

    // MARK: - Private IBOutlets

    @IBOutlet private var assetPriceView: AssetPriceView!
    @IBOutlet private var chartContainer: UIView!

    fileprivate var chartShimmeringView: ShimmeringView!

    // MARK: - Injected

    /// Presenter is injected from external source
    /// because the view should be compatible with queueing
    /// mechanism.
    public var presenter: AssetLineChartPresenterContainer! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let presenter = presenter else { return }
            assetPriceView.presenter = presenter.priceViewPresenter
            setupLineChartView(presenter.lineChartView)

            presenter.lineChartPresenter.state
                .bindAndCatch(to: rx.chartState)
                .disposed(by: disposeBag)
        }
    }

    fileprivate var chartView: LineChartView!
    private var disposeBag = DisposeBag()
    private var interactor: AssetLineChartUserInteractor!
    private var assetPricePresenter: InstantAssetPriceViewInteractor!
    private var chartContainerShimmeringView: ShimmeringView!

    // MARK: - Setup

    override public func awakeFromNib() {
        super.awakeFromNib()
        assetPriceView.shimmer(
            estimatedPriceLabelSize: CGSize(
                width: 150,
                height: 40
            ),
            estimatedChangeLabelSize: CGSize(
                width: 75,
                height: 24
            )
        )

        chartShimmeringView = ShimmeringView(
            in: self,
            centeredIn: chartContainer,
            size: .init(width: chartContainer.bounds.width, height: 1.0)
        )

        assetPriceView.setNeedsLayout()
        assetPriceView.layoutIfNeeded()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        fromNib(in: .module)
    }

    private func setupLineChartView(_ lineChartView: LineChartView) {
        chartView = lineChartView
        chartContainer.addSubview(chartView)
        chartView.fillSuperview()
    }
}

// MARK: - Rx

extension Reactive where Base: AssetLineChartView {
    public var chartData: Binder<(AssetLineChartMarkerView.Theme, LineChartData)> {
        Binder(base) { view, payload in
            let data = payload.1
            let theme = payload.0
            view.chartView.animate(yAxisDuration: 0.4)
            let marker = AssetLineChartMarkerView(
                frame: .init(
                    origin: .zero,
                    size: .init(
                        width: 8.0,
                        height: 8.0
                    )
                )
            )
            marker.theme = theme
            view.chartView.marker = marker
            view.chartView.data = data
            view.chartView.setNeedsDisplay()
        }
    }
}

extension Reactive where Base: AssetLineChartView {
    public var chartState: Binder<AssetLineChart.State.Presentation> {
        Binder(base) { view, payload in
            view.chartView.delegate?.chartValueNothingSelected?(view.chartView)
            view.chartView.marker = nil

            let state = payload
            let animation = {
                view.chartView.data = LineChartData.empty
                view.chartView.setNeedsDisplay()
                view.chartView.alpha = state.visibility.defaultAlpha
                view.chartShimmeringView.start()
            }
            let completion = { (_: Bool) in
                view.chartView.alpha = state.visibility.defaultAlpha
                view.chartShimmeringView.stop()
            }

            switch state {
            case .loading:
                UIView.animate(withDuration: 0.5, animations: animation)

            case .loaded(next: let value):
                UIView.animate(withDuration: 0.5, animations: animation) { finished in
                    completion(finished)
                    let theme = value.0
                    let data = value.1
                    view.chartView.animate(yAxisDuration: 0.4)
                    let marker = AssetLineChartMarkerView(
                        frame: .init(
                            origin: .zero,
                            size: .init(
                                width: 8.0,
                                height: 8.0
                            )
                        )
                    )
                    marker.theme = theme
                    view.chartView.marker = marker
                    view.chartView.data = data
                    view.chartView.setNeedsDisplay()
                }
            }
        }
    }
}
