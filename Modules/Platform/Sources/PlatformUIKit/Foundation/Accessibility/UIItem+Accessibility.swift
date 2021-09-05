// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension UITabBarItem {
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

extension UIBarButtonItem {
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
