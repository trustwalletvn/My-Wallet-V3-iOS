// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension UITapGestureRecognizer {

    /// Checks if the tap occurred inside a specified range within a UILabel.
    /// See: https://stackoverflow.com/a/35789589
    ///
    /// Warning: Does not work for labels with left-aligned text
    ///
    /// - Parameters:
    ///   - label: the UILabel
    ///   - range: the NSRange
    /// - Returns: true if the tap occurred within `range`, otherwise, false
    public func didTapAttributedText(in label: UILabel, range: NSRange) -> Bool {
        guard let attributedText = label.attributedText else {
            return false
        }

        let textStorage = NSTextStorage(attributedString: attributedText)

        let layoutManager = NSLayoutManager()

        let textContainer = NSTextContainer(size: CGSize.zero)
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        layoutManager.addTextContainer(textContainer)

        textStorage.addLayoutManager(layoutManager)

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        let textContainerOffset = CGPoint(
            x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
            y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y
        )
        let locationOfTouchInTextContainer = CGPoint(
            x: locationOfTouchInLabel.x - textContainerOffset.x,
            y: locationOfTouchInLabel.y - textContainerOffset.y
        )
        let indexOfCharacter = layoutManager.characterIndex(
            for: locationOfTouchInTextContainer,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        return NSLocationInRange(indexOfCharacter, range)
    }
}
