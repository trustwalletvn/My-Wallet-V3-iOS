// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit

extension SettingsSectionType.CellType {
    var action: SettingsScreenAction {
        switch self {
        case .badge(let type, let presenter):
            guard !presenter.isLoading else { return .none }
            switch type {
            case .currencyPreference:
                return .showCurrencySelectionScreen
            case .emailVerification:
                return .showUpdateEmailScreen
            case .limits:
                return .launchKYC
            case .mobileVerification:
                return .showUpdateMobileScreen
            case .pitConnection:
                return .launchPIT
            case .recoveryPhrase:
                return .showBackupScreen
            }
        case .cards(let type):
            switch type {
            case .skeleton:
                return .none
            case .linked(let presenter):
                return .showRemoveCardScreen(presenter.cardData)
            case .add(let presenter):
                guard !presenter.isLoading else { return .none }
                return presenter.action
            }
        case .banks(let type):
            switch type {
            case .skeleton:
                return .none
            case .linked(let presenter):
                return .showRemoveBankScreen(presenter.data)
            case .add(let presenter):
                guard !presenter.isLoading else { return .none }
                return presenter.action
            }
        case .clipboard(let type):
            switch type {
            case .walletID:
                return .promptGuidCopy
            }
        case .plain(let type):
            switch type {
            case .changePassword:
                return .launchChangePassword
            case .changePIN:
                return .showChangePinScreen
            case .loginToWebWallet:
                return .launchWebLogin
            case .rateUs:
                return .showAppStore
            case .termsOfService:
                return .showURL(URL(string: Constants.Url.termsOfService)!)
            case .privacyPolicy:
                return .showURL(URL(string: Constants.Url.privacyPolicy)!)
            case .cookiesPolicy:
                return .showURL(URL(string: Constants.Url.cookiesPolicy)!)
            }
        case .switch:
            return .none
        }
    }
}
