// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// This enum aggregates possible action types that can be done in the dashboard
public enum SettingsScreenAction {
    case launchChangePassword
    case launchWebLogin
    case promptGuidCopy
    case launchKYC
    case launchPIT
    case showAppStore
    case showBackupScreen
    case showChangePinScreen
    case showCurrencySelectionScreen
    case showUpdateEmailScreen
    case showUpdateMobileScreen
    case showURL(URL)
    case showRemoveCardScreen(CardData)
    case showRemoveBankScreen(Beneficiary)
    case showAddCardScreen
    case showAddBankScreen(FiatCurrency)
    case none
}
