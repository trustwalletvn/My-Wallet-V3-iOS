// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class AssetLineChartUserInteractor: AssetLineChartUserInteracting, ChartViewDelegate {

    public var state: Observable<AssetLineChartInteractionState> {
        _ = setup
        return stateRelay
            .observeOn(MainScheduler.instance)
            .asObservable()
    }

    private lazy var setup: Void = {
        deselectedTrigger
            .map { .deselected }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        selectedIndexRelay
            .map { .selected($0) }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let disposeBag = DisposeBag()
    private let stateRelay = BehaviorRelay<AssetLineChartInteractionState>(value: .deselected)
    private let deselectedTrigger = PublishRelay<Void>()
    private var selectedIndex: Observable<Int> {
        selectedIndexRelay.asObservable()
    }

    private var selectedIndexRelay = PublishRelay<Int>()

    public init(chartView: LineChartView) {
        chartView.delegate = self
    }

    // MARK: - ChartViewDelegate

    public func chartViewDidEndPanning(_ chartView: ChartViewBase) {
        chartView.highlightValue(nil)
        deselectedTrigger.accept(())
    }

    public func chartValueNothingSelected(_ chartView: ChartViewBase) {
        deselectedTrigger.accept(())
    }

    public func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        guard let index = entry.data as? NSNumber else { return }
        selectedIndexRelay.accept(index.intValue)
    }
}
