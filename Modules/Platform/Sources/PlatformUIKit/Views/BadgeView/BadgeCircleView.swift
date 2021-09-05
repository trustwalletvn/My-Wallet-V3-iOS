// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

public struct BadgeCircleViewModel {

    public let fillRatioRelay = BehaviorRelay<Float>(value: 1)

    public var fillRatio: Observable<Float> {
        fillRatioRelay
            .map { min($0, 1) }
            .map { max($0, 0) }
            .asObservable()
    }

    public init() {}
}

public class BadgeCircleView: UIView {

    // MARK: - Public Properties

    public var model: BadgeCircleViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard model != nil else { return }
            model
                .fillRatio
                .map { CGFloat($0) }
                .bind { [weak self] fillRatio in
                    self?.strokeLayer.strokeEnd = fillRatio
                }
                .disposed(by: disposeBag)
        }
    }

    override public var layer: CAShapeLayer {
        super.layer as! CAShapeLayer
    }

    override public class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    // MARK: - Private Properties

    private let strokeWidth: CGFloat
    private let strokeLayer = CAShapeLayer()
    private var disposeBag = DisposeBag()

    // MARK: - Setup

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { nil }

    init(
        strokeColor: UIColor,
        strokeBackgroundColor: UIColor,
        fillColor: UIColor,
        strokeWidth: CGFloat
    ) {
        self.strokeWidth = strokeWidth

        super.init(frame: .zero)

        configure(layer, strokeColor: strokeBackgroundColor, fillColor: fillColor, strokeWidth: strokeWidth)
        configure(strokeLayer, strokeColor: strokeColor, fillColor: nil, strokeWidth: strokeWidth)
        layer.addSublayer(strokeLayer)
        isAccessibilityElement = false
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        configurePath(layer, strokeWidth: strokeWidth)
        configurePath(strokeLayer, strokeWidth: strokeWidth)
    }

    private func configure(_ layer: CAShapeLayer, strokeColor: UIColor, fillColor: UIColor?, strokeWidth: CGFloat) {
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = strokeWidth
        layer.lineCap = .round
        layer.fillColor = fillColor?.cgColor
    }

    private func configurePath(_ layer: CAShapeLayer, strokeWidth: CGFloat) {
        let strokeEnd = layer.strokeEnd
        let radius = CGFloat(min(bounds.midX - strokeWidth / 2, bounds.midY - strokeWidth / 2))
        layer.path = UIBezierPath(
            arcCenter: .init(x: bounds.midX, y: bounds.midY),
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi * 1.5,
            clockwise: true
        ).cgPath
        layer.strokeEnd = strokeEnd
    }
}
