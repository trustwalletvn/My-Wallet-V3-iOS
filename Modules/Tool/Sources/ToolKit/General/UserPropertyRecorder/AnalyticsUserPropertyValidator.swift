// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public final class AnalyticsUserPropertyValidator {

    // MARK: - Types

    public enum UserPropertyMaxLength {
        public static let name = 24
        public static let value = 36
    }

    public enum UserPropertyError: String, Error {
        case nameFormat
        case valueFormat
    }

    // MARK: - Setup

    public init() {}

    // MARK: - API

    /// Returns the truncated user property name
    public func truncated(name: String) -> String {
        String(name.prefix(UserPropertyMaxLength.name))
    }

    /// Returns the truncated user property value
    public func truncated(value: String) -> String {
        String(value.prefix(UserPropertyMaxLength.value))
    }

    /// Enforce the name format using regular expression matching
    public func validate(name: String) throws {
        let suffixLength = UserPropertyMaxLength.name - 1

        /// Expected pattern
        let generalPattern = "^[a-zA-Z][a-zA-Z0-9_]{0,\(suffixLength)}$"
        let generalRegex = try NSRegularExpression(pattern: generalPattern, options: [])
        let range = NSRange(location: 0, length: name.count)
        guard generalRegex.numberOfMatches(in: name, options: [], range: range) == 1 else {
            throw UserPropertyError.nameFormat
        }

        /// Reserved prefixes
        let prefixPattern = "^((firebase_)|(google_)|(ga_)).*$"
        let prefixRegex = try NSRegularExpression(pattern: prefixPattern, options: [])
        guard prefixRegex.numberOfMatches(in: name, options: [], range: range) == 0 else {
            throw UserPropertyError.nameFormat
        }
    }

    /// Enforce the value format using regular expression matching
    public func validate(value: String) throws {
        let regex = try NSRegularExpression(pattern: "^.{0,\(UserPropertyMaxLength.value)}$", options: [])
        let range = NSRange(location: 0, length: value.count)
        guard regex.numberOfMatches(in: value, options: [], range: range) == 1 else {
            throw UserPropertyError.valueFormat
        }
    }
}
