// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension DateFormatter {
    public static let iso8601Format: ISO8601DateFormatter = {
        ISO8601DateFormatter()
    }()

    public static let long: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        formatter.isLenient = true
        return formatter
    }()

    public static let medium: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.isLenient = true
        return formatter
    }()

    public static var nominalReadable: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM. dd, yyyy"
        formatter.isLenient = true
        return formatter
    }

    public static func ddMMyyyy(separatedBy separator: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd\(separator)MM\(separator)yyyy"
        formatter.isLenient = true
        return formatter
    }

    public static var elegantDateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM dd, yyyy @ h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        formatter.isLenient = true
        return formatter
    }

    /// The format that the server sends down the expiration date for session tokens
    ///
    /// [Read More](https://developer.apple.com/library/archive/qa/qa1480/_index.html)
    public static let utcSessionDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale.Posix
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.isLenient = true
        return formatter
    }()

    /// The format that the server sends down the expiration date for session tokens
    public static let sessionDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        formatter.locale = Locale.Posix
        formatter.isLenient = true
        return formatter
    }()

    /// The API expects the user's DOB to be formatted this way.
    public static let birthday: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.isLenient = true
        return formatter
    }()

    /// Card expiry date. e.g: 06/2022
    public static let cardExpirationDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yyyy"
        formatter.isLenient = true
        return formatter
    }()

    static let HTTPRequestDateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:SS'Z'"
        formatter.isLenient = true
        return formatter
    }()
}
