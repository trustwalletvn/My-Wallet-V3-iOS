// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit

extension SettingsSectionType.CellType.PlainCellType {

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.SettingsCell.Plain

    var title: String {
        switch self {
        case .rateUs:
            return LocalizationConstants.Settings.rateUs
        case .loginToWebWallet:
            return LocalizationConstants.Settings.loginToWebWallet
        case .changePassword:
            return LocalizationConstants.Settings.changePassword
        case .changePIN:
            return LocalizationConstants.Settings.changePIN
        case .termsOfService:
            return LocalizationConstants.Settings.termsOfService
        case .privacyPolicy:
            return LocalizationConstants.Settings.privacyPolicy
        case .cookiesPolicy:
            return LocalizationConstants.Settings.cookiesPolicy
        }
    }

    var accessibilityID: String {
        rawValue
    }

    var viewModel: PlainCellViewModel {
        .init(
            title: title,
            accessibilityID: "\(AccessibilityIDs.titleLabelFormat)\(accessibilityID)",
            titleAccessibilityID: "\(AccessibilityIDs.title).\(accessibilityID)"
        )
    }
}

extension SettingsSectionType.CellType.ClipboardCellType {

    private typealias AccessibilityIDs = Accessibility.Identifier.Settings.SettingsCell

    var title: String {
        switch self {
        case .walletID:
            return LocalizationConstants.Settings.walletID
        }
    }

    var accessibilityID: String {
        rawValue
    }

    var viewModel: ClipboardCellViewModel {
        .init(
            title: title,
            accessibilityID: "\(AccessibilityIDs.titleLabelFormat)\(accessibilityID)"
        )
    }
}
