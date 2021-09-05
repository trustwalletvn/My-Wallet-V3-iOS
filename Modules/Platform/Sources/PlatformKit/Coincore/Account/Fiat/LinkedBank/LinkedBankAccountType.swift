// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum LinkedBankAccountType {
    case savings
    case checking
    case unknown
}

extension LinkedBankAccountType {
    public var title: String {
        switch self {
        case .checking:
            return LocalizationConstants.Transaction.checking
        case .savings:
            return LocalizationConstants.Transaction.savings
        case .unknown:
            return ""
        }
    }
}

extension LinkedBankAccountType {
    init(from type: LinkedBankResponse.AccountType) {
        switch type {
        case .none:
            self = .unknown
        case .savings:
            self = .savings
        case .checking:
            self = .checking
        }
    }
}
