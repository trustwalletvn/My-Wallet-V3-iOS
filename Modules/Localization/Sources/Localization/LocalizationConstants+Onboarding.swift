// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    public enum Onboarding {}
}

extension LocalizationConstants.Onboarding {
    public enum WelcomeScreen {
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
            public static let recoverFunds = NSLocalizedString(
                "Recover Funds",
                comment: "Welcome screen: recover funds CTA button"
            )
        }

        public static let title = NSLocalizedString(
            "Welcome to Blockchain",
            comment: "Welcome screen: title"
        )
    }

    public enum PairingIntroScreen {
        public enum Instruction {
            public static let firstPrefix = NSLocalizedString(
                "Log in to your Blockchain Wallet via your PC or Mac at ",
                comment: "Pairing intro screen: first instruction prefix"
            )
            public static let firstSuffix = NSLocalizedString(
                "login.blockchain.com",
                comment: "Pairing intro screen: first instruction suffix"
            )
            public static let second = NSLocalizedString(
                "Go to Settings / General.",
                comment: "Pairing intro screen: second instruction"
            )
            public static let third = NSLocalizedString(
                "Click Show Pairing Code to reveal a QR Code, a square black & white barcode. Scan the code with your camera.",
                comment: "Pairing intro screen: third instruction"
            )
        }

        public static let title = NSLocalizedString(
            "Log In",
            comment: "Manual pairing screen title"
        )
        public static let primaryButton = NSLocalizedString(
            "Scan Pairing Code",
            comment: "Scan pairing code CTA button"
        )
        public static let secondaryButton = NSLocalizedString(
            "Manual Pairing",
            comment: "Manual pairing CTA button"
        )
    }

    public enum AutoPairingScreen {
        public static let title = NSLocalizedString(
            "Automatic Pairing",
            comment: "Automatic pairing screen title"
        )
        public enum ErrorAlert {
            public static let title = NSLocalizedString(
                "Error",
                comment: "Auto pairing error alert title"
            )
            public static let message = NSLocalizedString(
                "There was an error while scanning your pairing QR code",
                comment: "Auto pairing error alert message"
            )
            public static let scanAgain = NSLocalizedString(
                "Try Again",
                comment: "Auto pairing error alert scan again button"
            )
            public static let manualPairing = NSLocalizedString(
                "Cancel",
                comment: "Auto pairing error alert cancel button"
            )
        }
    }

    public enum ManualPairingScreen {
        public enum TwoFAAlert {
            public static let wrongCodeTitle = NSLocalizedString(
                "Verification code incorrect. Please double check the code we sent you and try again.",
                comment: "2FA alert: title"
            )
            public static let title = NSLocalizedString(
                "Verification Code",
                comment: "2FA alert: title"
            )
            public static let wrongCodeMessage = NSLocalizedString(
                "%d login attempts left. Please enter your %@ 2FA code",
                comment: "2FA alert: title"
            )
            public static let message = NSLocalizedString(
                "Please enter your %@ 2FA code",
                comment: "2FA alert: message"
            )
            public static let verifyButton = NSLocalizedString(
                "Verify",
                comment: "2FA alert: verify button"
            )
            public static let resendButton = NSLocalizedString(
                "Send again",
                comment: "2FA alert: resend button"
            )
        }

        public enum AccountLockedAlert {
            public static let title = NSLocalizedString(
                "Account locked",
                comment: "Locked account alert: title"
            )
            public static let message = NSLocalizedString(
                "Your wallet has been locked because of too many failed login attempts. You can try again in 4 hours.",
                comment: "Locked account alert: message"
            )
        }

        public static let title = NSLocalizedString(
            "Manual Pairing",
            comment: "Manual pairing screen title"
        )
        public static let button = NSLocalizedString(
            "Continue",
            comment: "Manual pairing screen CTA button"
        )
        public enum EmailAuthorizationAlert {
            public static let title = NSLocalizedString(
                "Authorization Required",
                comment: "Title for email authorization alert"
            )
            public static let message = NSLocalizedString(
                "Please check your email to approve this login attempt.",
                comment: "Message for email authorization alert"
            )
        }

        public enum RequestOtpMessageErrorAlert {
            public static let title = NSLocalizedString(
                "An Error Occurred",
                comment: "Title for alert displayed when an error occurrs during otp request"
            )
            public static let message = NSLocalizedString(
                "There was a problem sending the SMS code. Please try again later.",
                comment: "Message for alert displayed when an error occurrs during otp request"
            )
        }
    }

    public enum CreateWalletScreen {
        public static let title = NSLocalizedString(
            "Create New Wallet",
            comment: "Create new wallet screen title"
        )
        public static let button = NSLocalizedString(
            "Create Wallet",
            comment: "Create new wallet screen CTA button"
        )
        public enum TermsOfUse {
            public static let prefix = NSLocalizedString(
                "By creating a wallet you agree to Blockchain’s ",
                comment: "Create new wallet screen TOS prefix"
            )
            public static let termsOfServiceLink = NSLocalizedString(
                "Terms of Service",
                comment: "Create new wallet screen TOS terms part"
            )
            public static let linkDelimiter = NSLocalizedString(
                " & ",
                comment: "Create new wallet screen TOS terms part"
            )
            public static let privacyPolicyLink = NSLocalizedString(
                "Privacy Policy",
                comment: "Create new wallet screen TOS privacy policy part"
            )
        }

        // TODO: Format it properly
        public static let termsOfUseFormat = NSLocalizedString(
            "By creating a wallet you agree to Blockchain’s Terms of Services & Privacy Policy",
            comment: "Create new wallet screen terms of use text label"
        )
    }

    public enum PasswordRequiredScreen {
        public static let title = NSLocalizedString(
            "Password Required",
            comment: "Password required screen title"
        )
        public static let continueButton = NSLocalizedString(
            "Continue",
            comment: "Password required CTA"
        )
        public static let forgotButton = NSLocalizedString(
            "Forgot Password?",
            comment: "Forgot password CTA"
        )
        public static let forgetWalletButton = NSLocalizedString(
            "Forget Wallet",
            comment: "Forget wallet CTA"
        )
        public static let loadingLabel = NSLocalizedString(
            "Loading Your Wallet",
            comment: "Password required: Loading label after the user inserts password"
        )
        public static let description = NSLocalizedString(
            "You have logged out or there was an error decrypting your wallet file. Enter your password below to login.",
            comment: "Description of Password Required form"
        )
        public static let forgetWalletDescription = NSLocalizedString(
            "If you would like to forget this wallet and start over, press 'Forget Wallet'.",
            comment: "Description of forget wallet functionality."
        )
        public enum ForgotPasswordAlert {
            public static let title = NSLocalizedString(
                "Open Support",
                comment: "forgot password alert title"
            )
            public static let message = NSLocalizedString(
                "You will be redirected to\n%@.",
                comment: "forgot password alert body"
            )
        }

        public enum ForgetWalletAlert {
            public static let title = NSLocalizedString(
                "Warning",
                comment: "forget wallet alert title"
            )
            public static let message = NSLocalizedString(
                "This will erase all wallet data on this device. Please confirm you have your wallet information saved elsewhere, otherwise any bitcoin in this wallet will be inaccessible!",
                comment: "forget wallet alert body"
            )
            public static let forgetButton = NSLocalizedString(
                "Forget wallet",
                comment: "forget wallet alert button"
            )
        }
    }

    public enum RecoverFunds {
        public static let title = NSLocalizedString(
            "Recover Funds",
            comment: "Title of the recover funds screen"
        )
        public static let description = NSLocalizedString(
            "Enter your 12 recovery words with spaces to recover your funds & transactions",
            comment: "Description of what to type into the recover funds screen"
        )
        public static let placeholder = NSLocalizedString(
            "Recovery phrase",
            comment: "Placeholder for the text field on the Recover Funds screen."
        )
        public static let button = NSLocalizedString(
            "Continue",
            comment: "CTA on the recover funds screen"
        )
    }

    public static let createNewWallet = NSLocalizedString("Create New Wallet", comment: "")
    public static let termsOfServiceAndPrivacyPolicyNoticePrefix = NSLocalizedString("By creating a wallet you agree to Blockchain’s", comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they create a wallet")
    public static let automaticPairing = NSLocalizedString("Automatic Pairing", comment: "")
    public static let recoverFunds = NSLocalizedString("Recover Funds", comment: "")
    public static let recoverFundsOnlyIfForgotCredentials = NSLocalizedString("You should always pair or login if you have access to your Wallet ID and password. Recovering your funds will create a new Wallet ID. Would you like to continue?", comment: "")
    public static let askToUserOldWalletTitle = NSLocalizedString("We’ve detected a previous installation of Blockchain Wallet on your phone.", comment: "")
    public static let askToUserOldWalletMessage = NSLocalizedString("Please choose from the options below.", comment: "")
    public static let loginExistingWallet = NSLocalizedString("Login existing Wallet", comment: "")

    public enum IntroductionSheet {
        public static let next = NSLocalizedString("Next", comment: "Next")
        public enum Home {
            public static let title = NSLocalizedString("View Your Portfolio", comment: "View Your Portfolio")
            public static let description = NSLocalizedString(
                "Keep track of your crypto balances from your Wallet's dashboard. Your Wallet currently supports Bitcoin, Ether, Bitcoin Cash, Stellar XLM and PAX.",
                comment: "Keep track of your crypto balances from your Wallet's dashboard. Your Wallet currently supports Bitcoin, Ether, Bitcoin Cash, Stellar XLM and PAX."
            )
        }

        public enum Send {
            public static let title = NSLocalizedString("Send", comment: "Send")
            public static let description = NSLocalizedString(
                "Send crypto anywhere, anytime. All you need is the recipient’s crypto address.",
                comment: "Send crypto anywhere, anytime. All you need is the recipient’s crypto address."
            )
        }

        public enum Request {
            public static let title = NSLocalizedString("Request", comment: "Request")
            public static let description = NSLocalizedString(
                "To receive crypto, all the sender needs is your crypto's address. You can find these addresses here.",
                comment: "To receive crypto, all the sender needs is your crypto's address. You can find these addresses here."
            )
        }

        public enum Swap {
            public static let title = NSLocalizedString("Swap", comment: "Swap")
            public static let description = NSLocalizedString(
                "Trade crypto with low fees without leaving your wallet.",
                comment: "Trade crypto with low fees without leaving your wallet."
            )
        }

        public enum BuySell {
            public static let title = NSLocalizedString("Buy & Sell", comment: "Buy & Sell")
            public static let description = NSLocalizedString(
                "Jumpstart your crypto portfolio by easily buying and selling Bitcoin.",
                comment: "Jumpstart your crypto portfolio by easily buying and selling Bitcoin."
            )
        }
    }
}
