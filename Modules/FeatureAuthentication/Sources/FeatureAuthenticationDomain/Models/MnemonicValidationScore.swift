// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum MnemonicValidationScore: Equatable {

    /// There's no score as there is no entry
    case none

    /// There are not enough words to fulfill the complete requirement
    case incomplete

    /// There are more words than the required mnemonic length
    case excess

    /// Valid words have been provided
    /// and there are enough words to complete the mnemonic
    case valid

    /// There are enough words to complete the mnemonic
    /// However, one of the provided words is not included in the WordList
    /// `[NSRange]` is the range of the words that are incorrect
    case invalid([NSRange])

    /// The score is only valid if the mnemonic is complete
    public var isValid: Bool {
        switch self {
        case .valid:
            return true
        case .incomplete, .invalid, .excess, .none:
            return false
        }
    }

    public var isInvalid: Bool {
        switch self {
        case .invalid, .excess:
            return true
        case .valid, .incomplete, .none:
            return false
        }
    }
}

extension MnemonicValidationScore {
    public static func == (lhs: MnemonicValidationScore, rhs: MnemonicValidationScore) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none),
             (.incomplete, .incomplete),
             (.valid, .valid),
             (.excess, .excess):
            return true
        case (.invalid(let left), .invalid(let right)):
            return left == right
        default:
            return false
        }
    }
}
