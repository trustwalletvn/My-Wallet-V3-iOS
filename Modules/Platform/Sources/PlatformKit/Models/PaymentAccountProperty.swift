// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum PaymentAccountProperty {

    /// States in which a `PaymentAccount` can be.
    public enum State: String, Codable {
        case pending = "PENDING"
        case active = "ACTIVE"
        case blocked = "BLOCKED"
    }

    /// Fields that can be part of a `PaymentAccount`.
    public enum Field: Hashable {
        case accountNumber(String)
        case sortCode(String)
        case recipientName(String)
        case routingNumber(String)
        case bankName(String)
        case bankCountry(String)
        case iban(String)
        case bankCode(String)

        public var content: String {
            switch self {
            case .accountNumber(let value):
                return value
            case .sortCode(let value):
                return value
            case .recipientName(let value):
                return value
            case .routingNumber(let value):
                return value
            case .bankName(let value):
                return value
            case .bankCountry(let value):
                return value
            case .iban(let value):
                return value
            case .bankCode(let value):
                return value
            }
        }

        public var title: String {
            typealias LocalizedString = LocalizationConstants.LineItem.Transactional
            switch self {
            case .accountNumber:
                return LocalizedString.accountNumber
            case .sortCode:
                return LocalizedString.sortCode
            case .recipientName:
                return LocalizedString.recipient
            case .routingNumber:
                return LocalizedString.routingNumber
            case .bankName:
                return LocalizedString.bankName
            case .bankCountry:
                return LocalizedString.bankCountry
            case .iban:
                return LocalizedString.iban
            case .bankCode:
                return LocalizedString.bankCode
            }
        }
    }
}
