// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import stellarsdk

/// We track error types that occur in Swap. This protocol makes getting the error type
/// simpler regardless of the type of `StellarServiceError`.
public protocol StellarServiceError: Error {
    var message: String { get }
}

/// `StellarAccountError` is a `TransactionValidationError` as all cases should cause
/// a transaction to be invalid.
public enum StellarAccountError: StellarServiceError, TransactionValidationError {
    case noDefaultAccount
    case noXLMAccount
    case unableToSaveNewAccount
}

extension StellarAccountError {
    public var message: String {
        switch self {
        case .noXLMAccount:
            return "noXLMAccount"
        case .noDefaultAccount:
            return "noDefaultAccount"
        case .unableToSaveNewAccount:
            return "unableToSaveNewAccount"
        }
    }
}

/// `StellarFundsError` is a `TransactionValidationError` as all cases should cause
/// a transaction to be invalid.
public enum StellarFundsError: StellarServiceError, TransactionValidationError {
    case insufficientFundsForNewAccount
    case insufficientFunds
}

extension StellarFundsError {
    public var message: String {
        switch self {
        case .insufficientFundsForNewAccount:
            return "insufficientFundsForNewAccount"
        case .insufficientFunds:
            return "insufficientFunds"
        }
    }
}

/// `StellarNetworkError` is not a `TransactionValidationError` as these errors would
/// not involve transaction validation. A transaction would not be able to be validated
/// should any of these errors occur.
public enum StellarNetworkError: StellarServiceError, Equatable {
    case rateLimitExceeded
    case internalError
    case parsingError
    case unauthorized
    case forbidden
    case badRequest(message: String)
    case unknown
}

extension StellarNetworkError {
    public var message: String {
        switch self {
        case .rateLimitExceeded:
            return "rateLimitExceeded"
        case .internalError:
            return "internalError"
        case .parsingError:
            return "parsingError"
        case .unauthorized:
            return "unauthorized"
        case .forbidden:
            return "forbidden"
        case .badRequest(let message):
            return message
        case .unknown:
            return "unknown"
        }
    }
}

extension StellarNetworkError {
    public static func == (lhs: StellarNetworkError, rhs: StellarNetworkError) -> Bool {
        switch (lhs, rhs) {
        case (.rateLimitExceeded, .rateLimitExceeded),
             (.internalError, .internalError),
             (.parsingError, .parsingError),
             (.unauthorized, .unauthorized),
             (.forbidden, .forbidden),
             (.unknown, .unknown):
            return true
        case (.badRequest(let lhs), .badRequest(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

extension HorizonRequestError {
    public func toStellarServiceError() -> StellarServiceError {
        switch self {
        case .notFound:
            return StellarAccountError.noDefaultAccount
        case .rateLimitExceeded:
            return StellarNetworkError.rateLimitExceeded
        case .internalServerError:
            return StellarNetworkError.internalError
        case .parsingResponseFailed:
            return StellarNetworkError.parsingError
        case .forbidden:
            return StellarNetworkError.forbidden
        case .badRequest(message: let message, horizonErrorResponse: let response):
            var value = message
            if let response = response {
                value += (" " + response.extras.resultCodes.transaction)
                value += (" " + response.extras.resultCodes.operations.joined(separator: " "))
            }
            return StellarNetworkError.badRequest(message: value)
        default:
            return StellarNetworkError.unknown
        }
    }
}
