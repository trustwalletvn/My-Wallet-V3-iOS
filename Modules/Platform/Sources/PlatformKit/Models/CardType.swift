// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public enum CardType: String {
    case visa = "VISA"
    case mastercard = "MASTERCARD"
    case amex = "AMEX"
    case diners = "DINERS"
    case discover = "DISCOVER"
    case jcb = "JCB"
    case unknown

    public static let all: Set<CardType> = [.visa, .mastercard, .amex, .diners, .discover, .jcb]

    public static let maxPossibleLength = 19

    public static func determineType(from number: String) -> CardType {
        let type = CardType.all.first(where: { type in
            for prefix in type.prefixes {
                if number.hasPrefix(prefix) {
                    return true
                }
            }
            return false
        })
        return type ?? .unknown
    }

    public var isKnown: Bool {
        switch self {
        case .unknown:
            return false
        default:
            return true
        }
    }

    public var regex: String {
        switch self {
        case .visa:
            return "^4\\d{12}(?:\\d{3})?$"
        case .mastercard:
            return "^5[1-5][0-9]{14}$|^2(?:2(?:2[1-9]|[3-9][0-9])|[3-6][0-9][0-9]|7(?:[01][0-9]|20))[0-9]{12}$"
        case .amex:
            return "^3[47]\\d{13}$"
        case .diners:
            return "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
        case .discover:
            return "^(?:6011\\d{12})|(?:65\\d{14})$"
        case .jcb:
            return "^(?:2131|1800|35[0-9]{3})[0-9]{11}$"
        case .unknown:
            return "^.*$"
        }
    }

    public var prefixes: Set<String> {
        switch self {
        case .visa:
            return ["4"]
        case .mastercard:
            return Set((51...55).map { String($0) })
        case .amex:
            return ["34", "37"]
        case .diners:
            return Set((300...305).map { String($0) } + ["36", "38"])
        case .discover:
            return ["6011", "65"]
        case .jcb:
            return ["2131", "1800", "35"]
        case .unknown:
            return []
        }
    }

    public var cvvLength: Int {
        switch self {
        case .amex:
            return 4
        case .discover, .diners, .jcb, .mastercard, .visa:
            return 3
        case .unknown:
            return 3
        }
    }

    public var name: String {
        typealias LocalizedString = LocalizationConstants.TextField.CardType
        switch self {
        case .visa:
            return LocalizedString.visa
        case .mastercard:
            return LocalizedString.mastercard
        case .amex:
            return LocalizedString.amex
        case .diners:
            return LocalizedString.diners
        case .discover:
            return LocalizedString.discover
        case .jcb:
            return LocalizedString.jcb
        case .unknown:
            return LocalizedString.unknown
        }
    }
}
