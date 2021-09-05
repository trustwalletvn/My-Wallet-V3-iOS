// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

final class AccessibilityIdentifiers: NSObject {

    enum WelcomeScreen {
        static let prefix = "WelcomeScreen."

        static let blockchainImage = "\(prefix)blockchainImage"
        static let welcomeTitleText = "\(prefix)titleText"
        static let welcomeMessageText = "\(prefix)messageText"
        static let createWalletButton = "\(prefix)createWalletButton"
        static let emailLoginButton = "\(prefix)emailLoginButton"
        static let restoreWalletButton = "\(prefix)restoreWalletButton"
        static let manualPairingButton = "\(prefix)manualPairingButton"
        static let buildVersionText = "\(prefix)buildVersionText"
    }

    enum SecondPasswordScreen {
        static let prefix = "SecondPasswordScreen."

        static let lockedIconImage = "\(prefix)lockedIconImage"
        static let titleText = "\(prefix)titleText"
        static let descriptionText = "\(prefix)descriptionText"
        static let learnMoreText = "\(prefix)learnMoreText"
        static let loginOnWebButton = "\(prefix)loginWithWebButton"
    }

    enum EmailLoginScreen {
        static let prefix = "EmailLoginScreen."

        static let emailGroup = "\(prefix)emailGroup"
        static let continueButton = "\(prefix)continueButton"
        static let loginTitleText = "\(prefix)loginTitleText"
    }

    enum ManualPairingScreen {
        static let prefix = "ManualPairingScreen."

        static let guidGroup = "\(prefix)guidGroup"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let continueButton = "\(prefix)continueButton"
    }

    enum VerifyDeviceScreen {
        static let prefix = "VerifyDeviceScreen."

        static let verifyDeviceImage = "\(prefix)verifyDeviceImage"
        static let verifyDeviceTitleText = "\(prefix)verifyDeviceTitleText"
        static let verifyDeviceDescriptionText = "\(prefix)verifyDeviceDescriptionText"
        static let sendAgainButton = "\(prefix)sendAgainButton"
        static let openMailAppButton = "\(prefix)openMailAppButton"
    }

    enum CredentialsScreen {
        static let prefix = "CredentialsScreen."

        static let emailGuidGroup = "\(prefix)emailGuidGroup"
        static let guidGroup = "\(prefix)guidGroup"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let troubleLoggingInButton = "\(prefix)troubleLoggingInButton"
        static let twoFAGroup = "\(prefix)twoFAGroup"
        static let resendSMSButton = "\(prefix)resendSMSButton"
        static let resetTwoFAButton = "\(prefix)resetTwoFAButton"
        static let hardwareKeyGroup = "\(prefix)hardwareKeyGroup"
    }

    enum SeedPhraseScreen {
        static let prefix = "SeedPhraseScreen."

        static let instructionText = "\(prefix)instructionText"
        static let seedPhraseTextEditor = "\(prefix)seedPhraseTextEditor"
        static let invalidPhraseErrorText = "\(prefix)invalidPhraseErrorText"
        static let resetAccountPromptText = "\(prefix)resetAccountPromptText"
        static let resetAccountButton = "\(prefix)resetAccountButton"
        static let logInButton = "\(prefix)logInButton"
    }

    enum ResetAccountWarningScreen {
        static let prefix = "ResetAccountModal."

        static let resetAccountImage = "\(prefix)resetAccountImage"
        static let resetAccountTitleText = "\(prefix)resetAccountTitleText"
        static let resetAccountMessageText = "\(prefix)resetAccountMessageText"
        static let continueToResetButton = "\(prefix)continueToResetButton"
        static let retryRecoveryPhraseButton = "\(prefix)retryRecoveryPhraseButton"
    }

    enum LostFundsWarningScreen {
        static let prefix = "LostFundsWarningScreen."

        static let lostFundsWarningImage = "\(prefix)lostFundsWarningImage"
        static let lostFundsWarningTitleText = "\(prefix)lostFundsWarningTitleText"
        static let lostFundsWarningMessageText = "\(prefix)lostFundsWarningMessageText"
        static let resetAccountButton = "\(prefix)resetAccountButton"
        static let goBackButton = "\(prefix)goBackButton"
    }

    enum ResetPasswordScreen {
        static let prefix = "ResetPasswordScreen."

        static let newPasswordGroup = "\(prefix)newPasswordGroup"
        static let passwordInstructionText = "\(prefix)passwordInstructionText"
        static let passwordStrengthIndicatorGroup = "\(prefix)passwordStrengthIndicatorGroup"
        static let confirmNewPasswordGroup = "\(prefix)confirmNewPasswordGroup"
        static let securityCallOutGroup = "\(prefix)securityCallOutGroup"
        static let resetPasswordButton = "\(prefix)resetPasswordButton"
    }

    enum ImportWalletScreen {
        static let prefix = "ImportWalletScreen."

        static let importWalletImage = "\(prefix)importWalletImage"
        static let importWalletTitleText = "\(prefix)importWalletTitleText"
        static let importWalletMessageText = "\(prefix)importWalletMessageText"
        static let importWalletButton = "\(prefix)importWalletButton"
        static let goBackButton = "\(prefix)goBackButton"
    }

    enum CreateAccountScreen {
        static let prefix = "CreateAccountScreen."

        static let emailGroup = "\(prefix)emailGroup"
        static let agreementPromptText = "\(prefix)agreementPromptText"
        static let termsOfServiceButton = "\(prefix)termsOfServiceButton"
        static let privacyPolicyButton = "\(prefix)privacyPolicyButton"
        static let passwordGroup = "\(prefix)passwordGroup"
        static let passwordInstructionText = "\(prefix)passwordInstructionText"
        static let passwordStrengthIndicatorGroup = "\(prefix)passwordStrengthIndicatorGroup"
        static let confirmPasswordGroup = "\(prefix)confirmPasswordGroup"
        static let createAccountButton = "\(prefix)createAccountButton"
    }
}
