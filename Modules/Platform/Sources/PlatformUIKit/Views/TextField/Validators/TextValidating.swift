// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public enum TextValidationState {

    // The text is valid
    case valid

    /// The text is invalid
    case invalid(reason: String?)

    var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .invalid:
            return false
        }
    }
}

/// A source of text stream
public protocol TextSource: AnyObject {
    var valueRelay: BehaviorRelay<String> { get }
}

/// Text validation mechanism
public protocol TextValidating: TextSource {
    var validationState: Observable<TextValidationState> { get }
    var isValid: Observable<Bool> { get }
}

extension TextValidating {
    public var isValid: Observable<Bool> {
        validationState.map(\.isValid)
    }
}
