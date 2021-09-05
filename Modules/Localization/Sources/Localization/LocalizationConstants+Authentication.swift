// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum FeatureAuthentication {}
}

extension LocalizationConstants.FeatureAuthentication {

    // MARK: - Welcome

    public enum Welcome {
        public enum Description {
            public static let prefix = NSLocalizedString(
                "The easy way to ",
                comment: "Welcome screen description: description prefix"
            )
            public static let comma = NSLocalizedString(
                ", ",
                comment: "Welcome screen description: comma separator"
            )
            public static let send = NSLocalizedString(
                "send",
                comment: "Welcome screen description: send word"
            )
            public static let receive = NSLocalizedString(
                "receive",
                comment: "Welcome screen description: receive word"
            )
            public static let store = NSLocalizedString(
                "store",
                comment: "Welcome screen description: store word"
            )
            public static let and = NSLocalizedString(
                " and ",
                comment: "Welcome screen description: store word"
            )
            public static let trade = NSLocalizedString(
                "trade",
                comment: "Welcome screen description: trade word"
            )
            public static let suffix = NSLocalizedString(
                " digital currencies.",
                comment: "Welcome screen description: suffix"
            )
        }

        public enum Button {
            public static let createWallet = NSLocalizedString(
                "Create a Wallet",
                comment: "Welcome screen: create wallet CTA button"
            )
            public static let login = NSLocalizedString(
                "Log In",
                comment: "Welcome screen: login CTA button"
            )
            public static let manualPairing = NSLocalizedString(
                "Manual Login",
                comment: "Welcome screen: manual pairing CTA button"
            )
            public static let restoreWallet = NSLocalizedString(
                "Restore Wallet",
                comment: "Welcome screen: restore wallet CTA button"
            )
        }

        public static let title = NSLocalizedString(
            "Welcome to Blockchain",
            comment: "Welcome screen: title"
        )
    }

    // MARK: - Email Login

    public enum EmailLogin {
        public static let navigationTitle = NSLocalizedString(
            "Log In",
            comment: "Login screen: login form title"
        )
        public static let manualPairingTitle = NSLocalizedString(
            "Manual Pairing Login",
            comment: "Manual Pairing screen: title"
        )
        public enum VerifyDevice {
            public static let title = NSLocalizedString(
                "Verify Device",
                comment: "Verify device screen: Verify device screen title"
            )
            public static let description = NSLocalizedString(
                "If you have an account registered with this email address, you will receive an email with a link to verify your device.",
                comment: "Verify device screen: Verify device screen description"
            )
            public enum Button {}
        }

        public enum TextFieldTitle {
            public static let walletIdentifier = NSLocalizedString(
                "Wallet Identifier",
                comment: "Login screen: wallet identifier field title"
            )
            public static let email = NSLocalizedString(
                "Email",
                comment: "Login screen: email text field title"
            )
            public static let password = NSLocalizedString(
                "Password",
                comment: "Login screen: password field title"
            )
            public static let twoFACode = NSLocalizedString(
                "2FA Code",
                comment: "Login screen: two factor authentication text field title"
            )
            public static let hardwareKeyCode = NSLocalizedString(
                "Verify with your |HARDWARE KEY|",
                comment: "Login screen: verify with hardware key title prefix"
            )
        }

        public enum TextFieldPlaceholder {
            public static let email = NSLocalizedString(
                "your@email.com",
                comment: "Login screen: placeholder for email text field"
            )
        }

        public enum TextFieldFootnote {
            public static let email = NSLocalizedString(
                "Email: ",
                comment: "Login screen: prefix for email on footnote"
            )
            public static let wallet = NSLocalizedString(
                "Wallet: ",
                comment: "Login screen: prefix for wallet identifier footnote"
            )
            public static let hardwareKeyInstruction = NSLocalizedString(
                "Tap |HARDWARE KEY| to verify",
                comment: "Login screen: hardware key usage instruction"
            )
            public static let lostTwoFACodePrompt = NSLocalizedString(
                "Lost access to your 2FA device?",
                comment: "Login screen: a prompt for user to reset their 2FA if they lost their 2FA device"
            )
        }

        public enum TextFieldError {
            public static let invalidEmail = NSLocalizedString(
                "Invalid Email",
                comment: "Login screen: invalid email error"
            )
            public static let incorrectWalletIdentifier = NSLocalizedString(
                "Incorrect Wallet Identifier",
                comment: "Manual Login screen: incorrect wallet identifier"
            )
            public static let incorrectPassword = NSLocalizedString(
                "Incorrect Password",
                comment: "Login screen: wrong password error"
            )
            public static let missingTwoFACode = NSLocalizedString(
                "Missing 2FA code",
                comment: "Login screen: missing 2FA code error"
            )
            public static let incorrectTwoFACode = NSLocalizedString(
                "Incorrect 2FA code. %d attempts left",
                comment: "Login screen: wrong 2FA code error"
            )
            public static let incorrectHardwareKeyCode = NSLocalizedString(
                "Incorrect |HARDWARE KEY| code",
                comment: "Login screen: wrong hardware key error"
            )
            public static let accountLocked = NSLocalizedString(
                "This account has been locked due to too many failed authentications",
                comment: "Login screen: a message saying that the account is locked"
            )
        }

        public enum Link {
            public static let troubleLogInLink = NSLocalizedString(
                "Trouble logging in?",
                comment: "Login screen: link for forgot password"
            )
            public static let resetTwoFALink = NSLocalizedString(
                "Reset your 2FA",
                comment: "Login screen: link for resetting 2FA"
            )
        }

        public enum Divider {
            public static let or = NSLocalizedString(
                "or",
                comment: "Login screen: Divider OR label"
            )
        }

        public enum Button {
            public static let scanPairingCode = NSLocalizedString(
                "Scan Pairing Code",
                comment: "Login screen: scan pairing code CTA button"
            )
            public static let openEmail = NSLocalizedString(
                "Open Email App",
                comment: "Verify device screen: Open email app CTA button"
            )
            public static let sendAgain = NSLocalizedString(
                "Send Again",
                comment: "Verify device screen: Send email again CTA button"
            )
            public static let apple = NSLocalizedString(
                "Continue with Apple",
                comment: "Login screen: sign in with Apple CTA button"
            )
            public static let google = NSLocalizedString(
                "Continue with Google",
                comment: "Login screen: sign in with Google CTA button"
            )
            public static let _continue = NSLocalizedString(
                "Continue",
                comment: "Login screen: continue CTA button"
            )
            public static let resendSMS = NSLocalizedString(
                "Resend SMS",
                comment: "Login screen: resend SMS for 2FA CTA button"
            )
        }
    }

    // MARK: - Import Wallet

    public enum ImportWallet {
        public static let importWalletTitle = NSLocalizedString(
            "Import Your Wallet?",
            comment: "Import Wallet Screen: title"
        )
        public static let importWalletMessage = NSLocalizedString(
            "There’s no account associated with the seed phrase you entered. You can import and manage your wallet instead.",
            comment: "Import Wallet Screen: message"
        )
        public enum Button {
            public static let importWallet = NSLocalizedString(
                "Import Wallet",
                comment: "Import Wallet screen: import wallet CTA button"
            )
            public static let goBack = NSLocalizedString(
                "Go Back",
                comment: "Import Wallet screen: go back CTA button"
            )
        }
    }

    // MARK: - Create Account

    public enum CreateAccount {
        public static let navigationTitle = NSLocalizedString(
            "Create Account",
            comment: "Create Account screen: navigation title"
        )
        public enum TextFieldTitle {
            public static let email = NSLocalizedString(
                "Email",
                comment: "Create Account screen: email text field"
            )
            public static let password = NSLocalizedString(
                "Password",
                comment: "Create Account screen: password text field"
            )
            public static let confirmPassword = NSLocalizedString(
                "Confirm New Password",
                comment: "Create Account screen: confirm password text field"
            )
        }

        public static let passwordInstruction = NSLocalizedString(
            "Use at least 8 characters and a mix of letters, numbers, and symbols",
            comment: "Reset password screen: password instruction"
        )
        public enum TextFieldPlaceholder {
            public static let email = NSLocalizedString(
                "your@email.com",
                comment: "Create Account screen: email text field placeholder"
            )
            public static let password = NSLocalizedString(
                "Enter new password",
                comment: "Create Account screen: password text field placeholder"
            )
            public static let confirmPassword = NSLocalizedString(
                "Re-enter new password",
                comment: "Create Account screen: confirm password text field placeholder"
            )
        }

        public enum TextFieldError {
            public static let invalidEmail = NSLocalizedString(
                "Invalid Email",
                comment: "Create Account screen: invalid email error"
            )
            public static let confirmPasswordNotMatch = NSLocalizedString(
                "Passwords don't match",
                comment: "Create Account screen: passwords do not match error"
            )
        }

        public static let agreementPrompt = NSLocalizedString(
            "By creating a wallet you agree to Blockchain’s",
            comment: "Create Account screen: agreement prompt footnote"
        )
        public static let termsOfServiceLink = NSLocalizedString(
            "Terms of Services",
            comment: "Create Account screen: terms of service link"
        )
        public static let and = NSLocalizedString(
            "and",
            comment: "Create Account screen: and (connective)"
        )
        public static let privacyPolicyLink = NSLocalizedString(
            "Privacy Policy",
            comment: "Create Account screen: privacy policy link"
        )
        public static let createAccountButton = NSLocalizedString(
            "Create Account",
            comment: "Create Account screen: create account CTA button"
        )
    }

    // MARK: - Seed Phrase

    public enum SeedPhrase {
        public enum NavigationTitle {
            public static let troubleLoggingIn = NSLocalizedString(
                "Trouble Logging In",
                comment: "Seed phrase screen: trouble logging in navigation title"
            )
            public static let importWallet = NSLocalizedString(
                "Import Wallet",
                comment: "Seed phrase screen: import wallet navigation title"
            )
        }

        public static let instruction = NSLocalizedString(
            "Enter your twelve word Secret Private Key Recovery Phrase to log in. Separate each word with a space.",
            comment: "Seed phrase screen: main instruction"
        )
        public static let placeholder = NSLocalizedString(
            "Enter recovery phrase",
            comment: "Seed phrase screen: text field placeholder"
        )
        public static let invalidPhrase = NSLocalizedString(
            "Invalid recovery phrase",
            comment: "Seed phrase screen: invalid seed phrase error state"
        )
        public static let resetAccountPrompt = NSLocalizedString(
            "Can’t find your phrase?",
            comment: "Seed phrase screen: prompt for reset account if user lost their seed phrase"
        )
        public static let resetAccountLink = NSLocalizedString(
            "Reset Account",
            comment: "Seed phrase screen: link for reset account"
        )
        public static let loginInButton = NSLocalizedString(
            "Log In",
            comment: "Seed phrase screen: login CTA button"
        )
    }

    // MARK: - Reset Account Warning

    public enum ResetAccountWarning {
        public enum Title {
            public static let resetAccount = NSLocalizedString(
                "Reset Your Account?",
                comment: "Reset Account Warning: title"
            )
            public static let lostFund = NSLocalizedString(
                "Resetting Account May Result In\nLost Funds",
                comment: "Lost Fund Warning: title"
            )
        }

        public enum Message {
            public static let resetAccount = NSLocalizedString(
                "Resetting will restore your Trading, Interest, and Exchange accounts.",
                comment: "Reset account warning: message"
            )
            public static let lostFund = NSLocalizedString(
                "This means that if you lose your recovery phrase, you will lose access to your Private Key Wallet funds. You can always restore your Private Key Wallet funds later if you find your recovery phrase.",
                comment: "Lost fund warning: message"
            )
        }

        public enum Button {
            public static let continueReset = NSLocalizedString(
                "Continue to Reset",
                comment: "Continue to reset CTA Button"
            )
            public static let retryRecoveryPhrase = NSLocalizedString(
                "Retry Recovery Phrase",
                comment: "Retry Recovery Phrase CTA Button"
            )
            public static let resetAccount = NSLocalizedString(
                "Reset Account",
                comment: "Reset Account CTA Button"
            )
            public static let goBack = NSLocalizedString(
                "Go Back",
                comment: "Go Back CTA Button"
            )
        }
    }

    // MARK: - Reset Password

    public enum ResetPassword {
        public static let navigationTitle = NSLocalizedString(
            "Reset Password",
            comment: "Reset password screen: navigation title"
        )
        public enum TextFieldTitle {
            public static let newPassword = NSLocalizedString(
                "New Password",
                comment: "Reset password screen: new password text field"
            )
            public static let confirmNewPassword = NSLocalizedString(
                "Confirm New Password",
                comment: "Reset password screen: confirm new password text field"
            )
        }

        public enum TextFieldPlaceholder {
            public static let newPassword = NSLocalizedString(
                "Enter new password",
                comment: "Reset password screen: new password text field"
            )
            public static let confirmNewPassword = NSLocalizedString(
                "Re-enter new password",
                comment: "Reset password screen: confirm new password text field"
            )
        }

        public static let passwordInstruction = NSLocalizedString(
            "Use at least 8 characters and a mix of letters, numbers, and symbols",
            comment: "Reset password screen: password instruction"
        )
        public static let confirmPasswordNotMatch = NSLocalizedString(
            "Passwords don't match",
            comment: "Reset password screen: passwords do not match error"
        )
        public static let securityCallOut = NSLocalizedString(
            "For your security, you may have to re-verify your identity before accessing your trading or interest account.",
            comment: "Seed phrase screen: callout message for the security measure"
        )
        public enum Button {
            public static let resetPassword = NSLocalizedString(
                "Reset Password",
                comment: "Reset password screen: reset password button"
            )
            public static let learnMore = NSLocalizedString(
                "Learn more",
                comment: "Reset password screen: learn more: identity verification."
            )
        }
    }

    // MARK: - Password Strength Indicator

    public enum PasswordStrength {
        public static let title = NSLocalizedString(
            "Password Strength",
            comment: "Reset password screen: password strength indicator title"
        )
        public static let weak = NSLocalizedString(
            "Weak",
            comment: "Reset password screen: password strength indicator: weak"
        )
        public static let medium = NSLocalizedString(
            "Medium",
            comment: "Reset password screen: password strength indicator: medium"
        )
        public static let strong = NSLocalizedString(
            "Strong",
            comment: "Reset password screen: password strength indicator: strong"
        )
    }
}
