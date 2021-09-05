// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public class LoadingCircleView: UIView {

    // MARK: - Properties

    /// The width of the stroke line
    private let strokeWidth: CGFloat

    override public var layer: CAShapeLayer {
        super.layer as! CAShapeLayer
    }

    override public class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    // MARK: - Setup

    init(
        diameter: CGFloat,
        strokeColor: UIColor,
        strokeBackgroundColor: UIColor,
        fillColor: UIColor,
        strokeWidth: CGFloat = 8
    ) {
        self.strokeWidth = strokeWidth
        super.init(frame: CGRect(origin: .zero, size: CGSize(edge: diameter)))
        configure(layer, strokeColor: strokeColor, fillColor: fillColor)
        let strokeBackgroundLayer = CAShapeLayer()
        configure(strokeBackgroundLayer, strokeColor: strokeBackgroundColor, fillColor: fillColor)
        layer.addSublayer(strokeBackgroundLayer)
        isAccessibilityElement = false
    }

    private func configure(_ layer: CAShapeLayer, strokeColor: UIColor, fillColor: UIColor) {
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = strokeWidth
        layer.lineCap = .round
        layer.fillColor = fillColor.cgColor
        layer.path = UIBezierPath(ovalIn: bounds.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2)).cgPath
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
