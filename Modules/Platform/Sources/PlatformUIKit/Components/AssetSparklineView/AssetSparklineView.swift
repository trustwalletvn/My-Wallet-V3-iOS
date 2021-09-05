// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

public final class AssetSparklineView: UIView {

    // MARK: - Injected

    public var presenter: AssetSparklinePresenter! {
        willSet {
            presenterDisposeBag = DisposeBag()
        }
        didSet {
            guard presenter != nil else {
                pathRelay.accept(nil)
                return
            }
            calculate()
        }
    }

    // MARK: - Private Properties

    private var path: Driver<UIBezierPath?> {
        pathRelay.asDriver()
    }

    private var lineColor: Driver<UIColor> {
        .just(presenter.lineColor)
    }

    private var fillColor: Driver<UIColor> {
        .just(.clear)
    }

    private var lineWidth: Driver<CGFloat> {
        .just(attributes.lineWidth)
    }

    private let pathRelay: BehaviorRelay<UIBezierPath?> = BehaviorRelay(value: nil)
    private let shape = CAShapeLayer()
    private let disposeBag = DisposeBag()
    private var presenterDisposeBag = DisposeBag()

    private var attributes: SparklineAttributes {
        .init(size: frame.size)
    }

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func calculate() {
        let calculator = SparklineCalculator(attributes: attributes)
        presenter
            .state
            .compactMap { state -> UIBezierPath? in
                switch state {
                case .valid(prices: let prices):
                    return calculator.sparkline(with: prices)
                case .empty, .invalid, .loading:
                    return nil
                }
            }
            .bindAndCatch(to: pathRelay)
            .disposed(by: presenterDisposeBag)

        lineColor
            .drive(shape.rx.strokeColor)
            .disposed(by: presenterDisposeBag)

        fillColor
            .drive(shape.rx.fillColor)
            .disposed(by: presenterDisposeBag)

        lineWidth
            .drive(shape.rx.lineWidth)
            .disposed(by: presenterDisposeBag)
    }

    private func setup() {
        if layer.sublayers == nil {
            shape.bounds = frame
            shape.position = center
            layer.addSublayer(shape)
        }

        path
            .drive(shape.rx.path)
            .disposed(by: disposeBag)
    }
}
