// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import UIKit

/// Convenience extension that enables initialization of a `UIView` from inside the view itself.
/// The nib is initialized as `contentView` of the owner view.
extension UIView {
    @discardableResult
    public func fromNib<T: UIView>(named nibName: String? = nil, in bundle: Bundle) -> T? {
        guard let contentView = bundle.loadNibNamed(
            nibName ?? Self.objectName,
            owner: self,
            options: nil
        )?.first as? T else {
            return nil
        }
        addSubview(contentView)
        contentView.layoutToSuperview(axis: .horizontal)
        contentView.layoutToSuperview(axis: .vertical)
        return contentView
    }
}
