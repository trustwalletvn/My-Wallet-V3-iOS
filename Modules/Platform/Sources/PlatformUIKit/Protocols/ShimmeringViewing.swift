// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum ShimmerDirection {
    case leftToRight
    case rightToLeft
}

/// Provides shimmering trait to the inheriting view
public protocol ShimmeringViewing: AnyObject {

    /// The direction of the shimmer
    var shimmerDirection: ShimmerDirection { get }

    /// Returns `true` if currently shimmering
    var isShimmering: Bool { get }
}

extension ShimmeringViewing where Self: UIView {

    public var shimmerDirection: ShimmerDirection {
        .leftToRight
    }

    public var isShimmering: Bool {
        layer.mask != nil
    }

    /// Starts the shimmerring of the view's content.
    ///  This works by applying a `CAGradientLayer` mask to the receiving `UIView` layer.
    /// - parameter color: The color of the central section of the shimmering effect, this will be set to this view `backgroundColor`.
    /// - parameter alpha: The alpha value of the central section of the gradient mask that will be used.
    public func startShimmering(color: UIColor, alpha: CGFloat = 1) {
        stopShimmering()
        backgroundColor = color
        let gradientLayer = CAGradientLayer()
        // Because `CAGradientLayer` will be used as a mask, only the alpha channel of its colors will be used.
        gradientLayer.colors = [
            UIColor.clear.cgColor,
            UIColor(white: 0, alpha: alpha).cgColor,
            UIColor.clear.cgColor
        ]
        gradientLayer.locations = [0, 0.5, 1]
        gradientLayer.transform = CATransform3DMakeRotation(0.25 * .pi, 0, 0, 1)
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        switch shimmerDirection {
        case .leftToRight:
            animation.fromValue = -bounds.width
            animation.toValue = bounds.width
        case .rightToLeft:
            animation.fromValue = bounds.width
            animation.toValue = -bounds.width
        }
        animation.duration = 3
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: "shimmering.x")
        gradientLayer.frame = bounds
        layer.mask = gradientLayer
    }

    /// Stops the shimerring effect
    public func stopShimmering() {
        backgroundColor = .clear
        layer.mask = nil
    }

    /// Should be called directly from `layoutSubviews`.
    public func layoutShimmeringFrameIfNeeded() {
        layer.mask?.frame = bounds
    }
}
