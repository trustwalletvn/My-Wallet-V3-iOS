// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class TodayAssetPriceViewPresenter {

    typealias PresentationState = LoadingState<Presentation>

    struct Presentation {

        // MARK: - Properties

        /// The price of the asset
        let price: LabelContent

        /// The change
        let change: NSAttributedString

        // MARK: - Setup

        init(with value: DashboardAsset.Value.Interaction.AssetPrice) {
            let fiatPrice = value.fiatValue.toDisplayString(includeSymbol: true)
            price = LabelContent(
                text: fiatPrice,
                font: .systemFont(ofSize: 16.0, weight: .semibold),
                color: .white,
                accessibility: .none
            )

            let color: UIColor

            if value.fiatChange.isPositive {
                color = .positivePrice
            } else if value.fiatChange.isNegative {
                color = .negativePrice
            } else { // Zero {
                color = .mutedText
            }

            let fiatChange: NSAttributedString
            let fiat = value.fiatChange.toDisplayString(includeSymbol: true)
            fiatChange = NSAttributedString(
                LabelContent(
                    text: "\(fiat) ",
                    font: .systemFont(ofSize: 12.0, weight: .semibold),
                    color: color
                )
            )

            let percentageChange: NSAttributedString
            let prefix = "("
            let suffix = ")"
            let percentage = value.changePercentage * 100
            let percentageString = percentage.string(with: 2)
            percentageChange = NSAttributedString(
                LabelContent(
                    text: "\(prefix)\(percentageString)%\(suffix)",
                    font: .systemFont(ofSize: 12.0, weight: .semibold),
                    color: color
                )
            )

            change = fiatChange + percentageChange
        }
    }

    // MARK: - Exposed Properties

    var state: Observable<PresentationState> {
        _ = setup
        return stateRelay
            .observeOn(MainScheduler.instance)
    }

    var alignment: Driver<UIStackView.Alignment> {
        alignmentRelay.asDriver()
    }

    // MARK: - Injected

    private let interactor: AssetPriceViewInteracting

    // MARK: - Private Accessors

    private lazy var setup: Void = {
        /// Map interaction state into presnetation state
        /// and bind it to `stateRelay`
        interactor.state
            .map(weak: self) { _, state -> PresentationState in
                .init(with: state)
            }
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }()

    private let alignmentRelay: BehaviorRelay<UIStackView.Alignment>
    private let stateRelay = BehaviorRelay<PresentationState>(value: .loading)
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        interactor: AssetPriceViewInteracting,
        alignment: UIStackView.Alignment = .fill
    ) {
        self.interactor = interactor
        alignmentRelay = BehaviorRelay<UIStackView.Alignment>(value: alignment)
    }
}

extension LoadingState where Content == TodayAssetPriceViewPresenter.Presentation {
    init(with state: LoadingState<DashboardAsset.Value.Interaction.AssetPrice>) {
        switch state {
        case .loading:
            self = .loading
        case .loaded(next: let content):
            self = .loaded(
                next: .init(
                    with: content
                )
            )
        }
    }
}
