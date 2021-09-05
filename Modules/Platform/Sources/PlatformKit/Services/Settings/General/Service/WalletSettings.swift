// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import Foundation

public struct WalletSettings: Equatable {

    public enum Feature: String {
        case segwit
    }

    public let countryCode: String
    public let language: String
    public let fiatCurrency: String
    public let email: String
    public let smsNumber: String?
    public let isSMSVerified: Bool
    public let isEmailNotificationsEnabled: Bool
    public let isEmailVerified: Bool
    public let authenticator: WalletAuthenticatorType
    public let features: [Feature: Bool]

    public var currency: FiatCurrency? {
        FiatCurrency(rawValue: fiatCurrency)
    }

    init(response: SettingsResponse) {
        countryCode = response.countryCode
        language = response.language
        fiatCurrency = response.currency
        email = response.email
        smsNumber = response.smsNumber
        isSMSVerified = response.smsVerified
        isEmailVerified = response.emailVerified
        isEmailNotificationsEnabled = response.emailNotificationsEnabled
        authenticator = WalletAuthenticatorType(rawValue: response.authenticator) ?? .standard
        features = response.invited.reduce(into: [Feature: Bool]()) { result, data in
            guard let key = Feature(rawValue: data.key.rawValue) else {
                return
            }
            result[key] = data.value
        }
    }
}
