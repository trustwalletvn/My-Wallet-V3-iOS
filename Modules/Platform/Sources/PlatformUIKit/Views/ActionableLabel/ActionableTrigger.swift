// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct ActionableTrigger: Equatable {
    public let primaryString: String
    public let callToAction: String
    public let secondaryString: String?
    public let execute: () -> Void

    public init(text: String, CTA: String, secondary: String? = nil, executionBlock: @escaping (() -> Void)) {
        primaryString = text
        secondaryString = secondary
        callToAction = CTA
        execute = executionBlock
    }

    public func actionRange() -> NSRange? {
        var text = primaryString + " " + callToAction
        if let secondary = secondaryString {
            text += " " + secondary
        }
        let value = NSString(string: text)
        return value.range(of: callToAction)
    }

    public static func == (lhs: ActionableTrigger, rhs: ActionableTrigger) -> Bool {
        lhs.primaryString == rhs.primaryString
            && lhs.secondaryString == rhs.secondaryString
            && lhs.callToAction == rhs.callToAction
    }
}
