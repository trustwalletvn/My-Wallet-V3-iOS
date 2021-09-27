// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

enum TargetSelectionInputValidation: Equatable {
    case empty
    case account(Account)
    case text(TextInput)
    case QR(QRInput)

    var textInput: TextInput? {
        switch self {
        case .text(let value):
            return value
        case .empty,
             .QR,
             .account:
            return nil
        }
    }

    var isAccountSelection: Bool {
        switch self {
        case .account:
            return true
        case .empty,
             .QR,
             .text:
            return false
        }
    }

    var isValid: Bool {
        switch self {
        case .QR(let input):
            return input.isValid
        case .account(let account):
            return account.isValid
        case .text(let input):
            return input.isValid
        case .empty:
            return false
        }
    }

    var text: String {
        switch self {
        case .text(let textInput):
            return textInput.textValue
        case .QR(let qrInput):
            return qrInput.text
        case .account,
             .empty:
            return ""
        }
    }

    var requiresValidation: Bool {
        switch self {
        case .QR,
             .account,
             .empty,
             .text:
            return false
        }
    }

    enum Account: Equatable {
        case none
        case account(BlockchainAccount)

        var isValid: Bool {
            switch self {
            case .account:
                return true
            case .none:
                return false
            }
        }
    }

    enum TextInput: Equatable {
        case inactive
        case invalid(String)
        case valid(ReceiveAddress)

        var textValue: String {
            switch self {
            case .inactive:
                return ""
            case .invalid(let value):
                return value
            case .valid(let receiveAddress):
                return receiveAddress.label.isEmpty ? receiveAddress.address : receiveAddress.label
            }
        }

        var isValid: Bool {
            switch self {
            case .valid:
                return true
            default:
                return false
            }
        }
    }

    /// When the user scans from the QR scanner the input can be
    /// an address with an optional amount or memo.
    enum QRInput: Equatable {
        /// The user has not scanned anything
        case empty
        // TODO: Accommodate an amount, memo, and the address
        case valid(CryptoReceiveAddress)

        var text: String {
            switch self {
            case .empty:
                return ""
            case .valid(let value):
                return value.address
            }
        }

        var isValid: Bool {
            switch self {
            case .valid:
                return true
            case .empty:
                return false
            }
        }
    }
}

extension TargetSelectionInputValidation.TextInput {
    static func == (lhs: TargetSelectionInputValidation.TextInput, rhs: TargetSelectionInputValidation.TextInput) -> Bool {
        switch (lhs, rhs) {
        case (.valid(let leftAddress), .valid(let rightAddress)):
            return leftAddress.address == rightAddress.address
        case (.invalid, .invalid),
             (.inactive, .inactive):
            return true
        default:
            return false
        }
    }
}

extension TargetSelectionInputValidation.QRInput {
    static func == (lhs: TargetSelectionInputValidation.QRInput, rhs: TargetSelectionInputValidation.QRInput) -> Bool {
        switch (lhs, rhs) {
        case (.valid(let leftAddress), .valid(let rightAddress)):
            return leftAddress.address == rightAddress.address
                && leftAddress.memo == rightAddress.memo
        case (.empty, .empty):
            return true
        default:
            return false
        }
    }
}

extension TargetSelectionInputValidation.Account {
    static func == (lhs: TargetSelectionInputValidation.Account, rhs: TargetSelectionInputValidation.Account) -> Bool {
        switch (lhs, rhs) {
        case (.account(let left), .account(let right)):
            return left.label == right.label
                && left.identifier == right.identifier
        case (.none, .none):
            return true
        default:
            return false
        }
    }
}
