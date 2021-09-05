// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension UIView {
    public func applyRadius(_ radius: CGFloat, to corners: UIRectCorner) {
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }

    public func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }

    public var imageRepresentation: UIImage? {
        setNeedsLayout()
        layoutIfNeeded()
        UIGraphicsBeginImageContextWithOptions(frame.size, true, UIScreen.main.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        layer.render(in: context)
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return image
    }
}
