// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public protocol ActionableLabelDelegate: AnyObject {

    /// This returns the range of the call to action text
    /// Users must tap within this range in order to trigger
    /// the delegate call back inidicating the CTA was tapped.
    func targetRange(_ label: ActionableLabel) -> NSRange?

    func actionRequestingExecution(label: ActionableLabel)
}

public final class ActionableLabel: UILabel {

    // MARK: Public Properties

    public weak var delegate: ActionableLabelDelegate?

    private var tapGesture: UITapGestureRecognizer!

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public init() {
        super.init(frame: CGRect.zero)
    }

    private func commonInit() {
        isUserInteractionEnabled = true
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(action(_:)))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)
    }

    // MARK: Touch Handling

    @objc private func action(_ tapGesture: UITapGestureRecognizer) {
        let location = tapGesture.location(in: self)
        guard let range = delegate?.targetRange(self) else { return }
        if didTap(inRange: range, location: location) {
            delegate?.actionRequestingExecution(label: self)
        }
    }

    // MARK: Actionable Helpers

    private func didTap(inRange targetRange: NSRange, location: CGPoint) -> Bool {
        guard let text = attributedText else { return false }
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
        let textStorage = NSTextStorage(attributedString: text)

        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = lineBreakMode
        textContainer.maximumNumberOfLines = numberOfLines

        let index = layoutManager.characterIndex(for: location, in: textContainer, fractionOfDistanceBetweenInsertionPoints: .none)

        return NSLocationInRange(index, targetRange)
    }
}
