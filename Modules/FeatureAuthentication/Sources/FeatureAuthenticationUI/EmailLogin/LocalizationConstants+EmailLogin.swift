// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

extension LocalizationConstants {
    enum EmailLogin {
        enum Alerts {
            enum SignInError {
                static let title = NSLocalizedString(
                    "Error Signing In",
                    comment: "Error alert title"
                )
                static let message = NSLocalizedString(
                    "For security reasons you cannot proceed with signing in.\nPlease try to log in on web.",
                    comment: "Error alert message"
                )
                static let continueTitle = NSLocalizedString(
                    "Continue",
                    comment: ""
                )
            }

            enum GenericNetworkError {
                static let title = NSLocalizedString(
                    "Network Error",
                    comment: ""
                )
                static let message = NSLocalizedString(
                    "We cannot establish a connection with our server.\nPlease try to sign in again.",
                    comment: ""
                )
            }
        }
    }

    enum CredentialsForm {
        enum Alerts {
            enum EmailAuthorizationAlert {
                public static let title = NSLocalizedString(
                    "Authorization Required",
                    comment: "Title for email authorization alert"
                )
                public static let message = NSLocalizedString(
                    "Please check your email to approve this login attempt.",
                    comment: "Message for email authorization alert"
                )
            }

            enum SMSCode {
                enum Failure {
                    static let title = NSLocalizedString(
                        "Error Sending SMS",
                        comment: "Error alert title when sms failed"
                    )

                    static let message = NSLocalizedString(
                        "There was an error sending you the SMS message.\nPlease try again.",
                        comment: "Error alert message when sms failed"
                    )
                }

                enum Success {
                    static let title = NSLocalizedString(
                        "Message sent",
                        comment: "Success alert title when sms sent"
                    )

                    static let message = NSLocalizedString(
                        "We have sent you a verification code message.",
                        comment: "Success alert message when sms sent"
                    )
                }
            }

            enum GenericNetworkError {
                static let title = NSLocalizedString(
                    "Network Error",
                    comment: ""
                )
                static let message = NSLocalizedString(
                    "We cannot establish a connection with our server.\nPlease try to sign in again.",
                    comment: ""
                )
            }
        }
    }
}
