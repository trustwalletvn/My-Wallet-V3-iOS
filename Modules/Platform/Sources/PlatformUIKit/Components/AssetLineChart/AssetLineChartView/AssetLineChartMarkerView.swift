// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Charts

/// A view displayed over the user's selection when dragging
/// across a `LineChartView` (or any chart view for that matter)
public class AssetLineChartMarkerView: MarkerView {

    public struct Theme {
        /// The color of the circle
        let lineColor: UIColor

        /// The fill color of the circle
        let fillColor: UIColor
    }

    var theme: Theme = .default

    private let strokeWidth: CGFloat = 2

    override public var layer: CAShapeLayer {
        super.layer as! CAShapeLayer
    }

    override public class var layerClass: AnyClass {
        CAShapeLayer.self
    }

    override public func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        super.refreshContent(entry: entry, highlight: highlight)
    }

    override public func draw(context: CGContext, point: CGPoint) {
        super.draw(context: context, point: point)
        layer.fillColor = theme.fillColor.cgColor
        layer.strokeColor = theme.lineColor.cgColor
        layer.lineWidth = strokeWidth
        layer.lineCap = .round
        layer.shadowColor = theme.lineColor.withAlphaComponent(0.8).cgColor
        layer.shadowOpacity = 1
        layer.shadowRadius = 4
        layer.path = UIBezierPath(
            ovalIn: bounds.offsetBy(
                dx: -bounds.width / 2.0,
                dy: -bounds.height / 2.0
            )
        ).cgPath
        isAccessibilityElement = false
    }
}

extension AssetLineChartMarkerView.Theme {
    static let `default`: AssetLineChartMarkerView.Theme = .init(lineColor: .primary, fillColor: .white)

    static let positive: AssetLineChartMarkerView.Theme = .init(lineColor: .positivePrice, fillColor: .white)

    static let negative: AssetLineChartMarkerView.Theme = .init(lineColor: .negativePrice, fillColor: .white)
}
