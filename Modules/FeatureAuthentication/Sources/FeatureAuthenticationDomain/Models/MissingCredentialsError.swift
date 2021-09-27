// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// An error thrown for missing credentials
public enum MissingCredentialsError: Error, Equatable {

    /// Cannot send request because of missing GUID
    case guid

    /// Cannot send request because of a missing session token
    case sessionToken

    /// Cannot send request because of a missing shared key
    case sharedKey

    /// Missing user id
    case userId

    /// Missing offline token
    case offlineToken
}

extension MissingCredentialsError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .guid:
            return "missing wallet GUID"
        case .sessionToken:
            return "missing session token"
        case .sharedKey:
            return "missing shared key"
        case .userId:
            return "missing user id"
        case .offlineToken:
            return "missing offline token"
        }
    }
}

public enum CredentialWritingError: Error {

    /// Error while writing the offline token
    case offlineToken
}

extension CredentialWritingError: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .offlineToken:
            return "Error while writing offline token"
        }
    }
}
