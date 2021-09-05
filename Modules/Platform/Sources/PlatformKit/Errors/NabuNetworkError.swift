// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import NetworkKit
import ToolKit

public struct NabuErrorDecodingFailure: Error {
    let id: String?
    let code: NabuErrorCode?
    let type: NabuErrorType?
    let description: String?
}

public enum NabuNetworkError: Error, Decodable {

    enum CodingKeys: CodingKey {
        case id
        case code
        case type
        case description
    }

    case nabuError(NabuError)
    case communicatorError(NetworkError)

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        let id = try values.decodeIfPresent(String.self, forKey: .id)
        var code: NabuErrorCode = .unknown
        var type: NabuErrorType = .unknown
        let description = try values.decodeIfPresent(String.self, forKey: .description)

        do {
            code = try values.decodeIfPresent(NabuErrorCode.self, forKey: .code) ?? .unknown
            type = try values.decodeIfPresent(NabuErrorType.self, forKey: .type) ?? .unknown
        } catch {
            #if INTERNAL_BUILD
            Self.crashOnUnknownCodeOrType(code: code, type: type, values: values)
            #else
            ProbabilisticRunner.run(for: .pointZeroOnePercent) {
                Self.crashOnUnknownCodeOrType(code: code, type: type, values: values)
            }
            #endif
            throw NabuErrorDecodingFailure(
                id: id,
                code: code,
                type: type,
                description: description
            )
        }
        self = .nabuError(NabuError(id: id, code: code, type: type, description: description))
    }

    public init(from communicatorError: NetworkError) {
        self = .communicatorError(communicatorError)
    }

    private static func crashOnUnknownCodeOrType(
        code: NabuErrorCode,
        type: NabuErrorType,
        values: KeyedDecodingContainer<NabuNetworkError.CodingKeys>
    ) {
        guard code == .unknown || type == .unknown else { return }

        var messages: [String] = []

        if code == .unknown {
            if let code = try? values.decode(Int.self, forKey: .code) {
                messages.append("Unknown code: \(code)")
            } else {
                messages.append("Missing code")
            }
        }

        if type == .unknown {
            if let type = try? values.decode(String.self, forKey: .type) {
                messages.append("Unknown type: \(type)")
            } else {
                messages.append("Missing type")
            }
        }

        fatalError(messages.joined(separator: ", "))
    }
}

extension NabuNetworkError: CustomStringConvertible {

    public var description: String {
        switch self {
        case .nabuError(let error):
            return String(describing: error)
        case .communicatorError(let error):
            return String(describing: error)
        }
    }
}

extension NabuNetworkError: Equatable {

    /// Just a simple implementation to bubble up this to UI States. We can improve on this if needed.
    public static func == (lhs: NabuNetworkError, rhs: NabuNetworkError) -> Bool {
        String(describing: lhs) == String(describing: rhs)
    }
}

extension NabuNetworkError: FromNetworkErrorConvertible {

    public static func from(_ communicatorError: NetworkError) -> NabuNetworkError {
        NabuNetworkError(from: communicatorError)
    }
}

/// Describes an error returned by Nabu
public struct NabuError: Error, Codable, Equatable, Identifiable {

    private enum CodingKeys: String, CodingKey {
        case id
        case code
        case type
        case serverDescription = "description"
    }

    public let id: String
    public let code: NabuErrorCode
    public let type: NabuErrorType
    public let serverDescription: String?

    public var localizedDescription: String? {
        description
    }

    public init(
        id: String?,
        code: NabuErrorCode,
        type: NabuErrorType,
        description: String?
    ) {
        self.id = id ?? Self.missingId()
        self.code = code
        self.type = type
        serverDescription = description
    }

    public init(
        id: String,
        code: NabuErrorCode,
        type: NabuErrorType,
        description: String?
    ) {
        self.id = id
        self.code = code
        self.type = type
        serverDescription = description
    }

    private static func missingId() -> String {
        "MISSING_ID_" + UUID().uuidString
    }
}

extension NabuError: CustomStringConvertible {

    /// Provides the error description that backend sent back,
    /// if no description is provided or in case it is empty the error code will be displayed
    /// otherwise the error will be in the form of "{error-description} - Error code: {code}"
    public var description: String {
        guard let description = serverDescription, !description.isEmpty else {
            return "\(LocalizationConstants.Errors.errorCode): \(code)"
        }
        return "\(description) - \(LocalizationConstants.Errors.errorCode): \(code)"
    }
}

public enum NabuErrorCode: Int, Codable, Equatable {

    // Unknown code
    case unknown = 0

    // Generic HTTP errors
    case internalServerError = 1
    case notFound = 2
    case badMethod = 3
    case conflict = 4

    // generic user input errors
    case missingBody = 5
    case missingParam = 6
    case badParamValue = 7

    // authentication errors
    case invalidCredentials = 8
    case wrongPassword = 9
    case wrong2fa = 10
    case bad2fa = 11
    case unknownUser = 12
    case invalidRole = 13
    case alreadyLoggedIn = 14
    case invalidStatus = 15

    // currency ratio errors
    case notSupportedCurrencyPair = 16
    case unknownCurrencyPair = 17
    case unknownCurrency = 18
    case currencyIsNotFiat = 19
    case tooSmallVolume = 26
    case tooBigVolume = 27
    case resultCurrencyRatioTooSmall = 28

    // conversion errors
    case providedVolumeIsNotDouble = 20
    case unknownConversionType = 21

    // kyc errors
    case userNotActive = 22
    case pendingKycReview = 23
    case kycAlreadyCompleted = 24
    case maxKycAttempts = 25
    case invalidCountryCode = 29

    // user-onboarding errors
    case invalidJwtToken = 30
    case expiredJwtToken = 31
    case mobileRegisteredAlready = 32
    case userRegisteredAlready = 33
    case missingApiToken = 34
    case couldNotInsertUser = 35
    case userRestored = 36

    // user trading error
    case genericTradingError = 37
    case albertExecutionError = 38
    case userHasNoCountry = 39
    case userNotFound = 40
    case orderBelowMinLimit = 41
    case wrongDepositAmount = 42
    case orderAboveMaxLimit = 43
    case ratesApiError = 44
    case dailyLimitExceeded = 45
    case weeklyLimitExceeded = 46
    case annualLimitExceeded = 47
    case notCryptoToCryptoCurrencyPair = 48
    case invalidCountryStateCode = 49
    case blockedPhone = 50
    case pendingOrdersLimitReached = 53
    case tradingDisabled = 51
    case mobileTooLong = 52

    /// Campaign Related Errors - These errors are specific
    /// to users opting into an air drop campaign. Currently they're
    /// used when a user deep links into the application from a campaign
    /// related link.
    case invalidCampaign = 54
    case invalidCampaignUser = 55
    case campaignUserAlreadyRegistered = 56
    case campaignExpired = 57
    case invalidCampaignInfo = 58
    case campaignWithdrawalFailed = 59
    case tradeForceExecuteError = 60
    case campaignInfoAlreadyUsed = 61

    case linkAccountError = 66
    case userAlreadyLinked = 660
    case linkExpired = 661

    case verificationExpired = 63
    case verificationFailed = 64
    case emailVerificationInProgress = 65
    case userHasNoUsername = 67
    case noAvailableUsername = 680
    case userNotAllowedToGetCredentials = 70
    case enablementFailed = 69

    // Payments related
    case depositCheckError = 72
    case couldNotInsertBeneficiary = 74
    case beneficiaryAlreadyExists = 75
    case beneficiaryNotFound = 76
    case paymentsNotSupported = 77
    case productNotSpecified = 78
    case notAuthorizedForFiat = 79
    case missingCryptoAddress = 87
    case missingBeneficiary = 88
    case invalidWithdrawalAmount = 90
    case exchangeRateFetchFailure = 91
    case minimumWithdrawalAmount = 92
    case invalidCryptoAddress = 93
    case invalidCryptoCurrency = 94
    case tierTooLow = 98
    case invalidAddress = 99
    case invalidPostcode = 158
    case notAuthorizedForGBP = 97
    case notAuthorizedForTry = 100
    case maxPaymentCards = 101
    case maxPaymentBankAccounts = 143
    case notAuthorizedForRub = 144
    case maxAuthAttemptsReached = 145

    /// Buy-Sell Error Code
    case withdrawalForbidden = 130
    case insufficientBalance = 131
    case orderInProgress = 132
    case simpleBuyExpirationError = 133
    case simpleBuyForceExecutionError = 134
    case invalidPaymentMethod = 135
    case noRatesAvailable = 136
    case eddQuestionairePending = 146
    /// Custodial Withdrawal Error Code
    case withdrawalLocked = 152

    /// Custodial related
    case invalidDestinationAddress = 148
    case invalidFiatCurrency = 149
    case orderDirectionDisabled = 151
    case addressGenerationFailure = 153
    case notFoundCustodialQuote = 155
    case userNotEligibleForSwap = 156
    case orderAmountNegative = 157

    case invalidKYCForSavings = 140
    case currencyNotSupported = 141
    case productNotSupported = 142
    case missingRangeParameter = 147
    case featureNotAvailable = 154

    case documentDataRequired = 160
}

public enum NabuErrorType: String, Codable, Equatable {

    // Unknown
    case unknown

    // Generic HTTP errors
    case internalServerError = "INTERNAL_SERVER_ERROR"
    case notFound = "NOT_FOUND"
    case badMethod = "BAD_METHOD"
    case conflict = "CONFLICT"

    // Generic user input errors
    case missingBody = "MISSING_BODY"
    case missinParam = "MISSING_PARAM"
    case badParamValue = "BAD_PARAM_VALUE"

    // Authentication errors
    case forbidden = "FORBIDDEN"
    case invalidCredentials = "INVALID_CREDENTIALS"
    case wrongPassword = "WRONG_PASSWORD"
    case wrong2FA = "WRONG_2FA"
    case bad2FA = "BAD_2FA"
    case unknownUser = "UNKNOWN_USER"
    case invalidRole = "INVALID_ROLE"
    case alreadyLoggedIn = "ALREADY_LOGGED_IN"
    case invalidStatus = "INVALID_STATUS"
}
