// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// An extension to `UIView` which contains all the accessibility
extension UIView {

    /// Represents a `UIView` accessibility.
    /// In case one of `Accessibility`'s properties are `.none`, the value won't be assigned at all
    /// To nullify a value just pass an `empty` value, like this: `nil` for id,
    /// or `.none)` for traits.
    public var accessibility: Accessibility {
        get {
            Accessibility(
                id: accessibilityIdentifier,
                label: accessibilityLabel,
                hint: accessibilityHint,
                traits: accessibilityTraits,
                isAccessible: isAccessibilityElement
            )
        }
        set {
            accessibilityIdentifier = newValue.id
            accessibilityLabel = newValue.label
            accessibilityHint = newValue.hint
            accessibilityTraits = newValue.traits
            isAccessibilityElement = newValue.isAccessible
        }
    }
}
