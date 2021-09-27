// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum FeeLevel: Equatable {
    case none
    case regular
    case priority
    case custom

    public var title: String {
        switch self {
        case .none:
            return ""
        case .regular:
            return LocalizationConstants.Transaction.Send.regular
        case .priority:
            return LocalizationConstants.Transaction.Send.priority
        case .custom:
            return LocalizationConstants.Transaction.Send.custom
        }
    }
}

extension Collection where Element == FeeLevel {
    /// If there's more than one `FeeLevel` (excluding `.none`)
    /// than the transaction supports adjusting the `FeeLevel`
    public var networkFeeAdjustmentSupported: Bool {
        filter { $0 != .none }.count > 1
    }
}
