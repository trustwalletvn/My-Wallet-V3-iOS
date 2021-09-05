// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {

    public enum KYC {
        public static let welcome = NSLocalizedString("Welcome", comment: "Welcome")
        public static let welcomeMainText = NSLocalizedString(
            "Introducing Blockchain's faster, smarter way to trade your crypto. Upgrade now to enjoy benefits such as better prices, higher trade limits and live rates.",
            comment: "Text displayed when user is starting KYC"
        )
        public static let welcomeMainTextSunRiverCampaign = NSLocalizedString(
            "Complete your profile to start instantly trading crypto from the security of your wallet and become eligible for our Airdrop Program.",
            comment: "Text displayed when user is starting KYC coming from the airdrop link"
        )
        public static let invalidPhoneNumber = NSLocalizedString(
            "The mobile number you entered is invalid.",
            comment: "Error message displayed to the user when the phone number they entered during KYC is invalid."
        )
        public static let failedToConfirmNumber = NSLocalizedString(
            "Failed to confirm mobile number. Please try again.",
            comment: "Error message displayed to the user when the mobile confirmation steps fails."
        )
        public static let termsOfServiceAndPrivacyPolicyNotice = NSLocalizedString(
            "By hitting \"Begin Now\", you agree to Blockchain’s %@ & %@",
            comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they start the KYC process."
        )
        public static let retryAction = NSLocalizedString(
            "Try Again",
            comment: "Action displayed when the SDD verification check completes but the user goes back to the same screen."
        )
        public static let verificationCompletedTitle = NSLocalizedString(
            "Verification complete",
            comment: "Text displayed when the SDD verification check completes but the user goes back to the same screen."
        )
        public static let verificationCompletedMessage = NSLocalizedString(
            "If you think something is wrong, you can try again or go back to the previous screen to update your info.",
            comment: "Text displayed when the SDD verification check completes but the user goes back to the same screen."
        )
        public static let verificationInProgress = NSLocalizedString(
            "Verification in Progress",
            comment: "Text displayed when KYC verification is in progress."
        )
        public static let verificationInProgressWait = NSLocalizedString(
            "This may take a few minutes to complete. Please wait.",
            comment: "Text displayed when KYC verification is in progress."
        )
        public static let verificationInProgressDescription = NSLocalizedString(
            "Your information is being reviewed. When all looks good, you’re clear to trade. You should receive a notification within 5 minutes.",
            comment: "Description for when KYC verification is in progress."
        )
        public static let verificationInProgressDescriptionAirdrop = NSLocalizedString(
            "Your information is being reviewed. The review should complete in 5 minutes. Please be aware there is a large waiting list for Stellar airdrops and unfortunately not all applications for free XLM will be successful.",
            comment: "Description for when KYC verification is in progress and the user is waiting for a Stellar airdrop."
        )
        public static let accountApproved = NSLocalizedString(
            "Account Approved",
            comment: "Text displayed when KYC verification is approved."
        )
        public static let accountApprovedDescription = NSLocalizedString(
            "Congratulations! We successfully verified your identity. You can now Exchange cryptocurrencies at Blockchain.",
            comment: "Description for when KYC verification is approved."
        )
        public static let accountApprovedBadge = NSLocalizedString(
            "Approved",
            comment: "KYC verification is approved."
        )
        public static let accountInReviewBadge = NSLocalizedString(
            "In Review",
            comment: "KYC verification is in Review."
        )
        public static let accountUnderReviewBadge = NSLocalizedString(
            "Under Review",
            comment: "KYC verification is under Review."
        )
        public static let verificationUnderReview = NSLocalizedString(
            "Verification Under Review",
            comment: "Text displayed when KYC verification is under review."
        )
        public static let verificationUnderReviewDescription = NSLocalizedString(
            "We had some trouble verifying your account with the documents provided. Our support team will contact you shortly to resolve this.",
            comment: "Description for when KYC verification is under review."
        )
        public static let accountUnconfirmedBadge = NSLocalizedString(
            "Unconfirmed",
            comment: "KYC verification is unconfirmed."
        )
        public static let accountUnverifiedBadge = NSLocalizedString(
            "Verify Now",
            comment: "Verify Now"
        )
        public static let accountVerifiedBadge = NSLocalizedString(
            "Verified",
            comment: "KYC verification is complete."
        )
        public static let verificationFailed = NSLocalizedString(
            "Verification Failed",
            comment: "Text displayed when KYC verification failed."
        )
        public static let verificationFailedBadge = NSLocalizedString(
            "Failed",
            comment: "Text displayed when KYC verification failed."
        )
        public static let verificationFailedDescription = NSLocalizedString(
            "Unfortunately we had some trouble verifying your identity with the documents you’ve supplied and your account can’t be verified at this time.",
            comment: "Description for when KYC verification failed."
        )
        public static let notifyMe = NSLocalizedString(
            "Notify Me",
            comment: "Title of the button the user can tap when they want to be notified of update with their KYC verification process."
        )
        public static let getStarted = NSLocalizedString(
            "Get Started",
            comment: "Title of the button the user can tap when they want to start trading on the Exchange. This is displayed after their KYC verification has been approved."
        )
        public static let contactSupport = NSLocalizedString(
            "Contact Support",
            comment: "Title of the button the user can tap when they want to contact support as a result of a failed KYC verification."
        )
        public static let whatHappensNext = NSLocalizedString(
            "What happens next?",
            comment: "Text displayed (subtitle) when KYC verification is under progress"
        )
        public static let comingSoonToX = NSLocalizedString(
            "Coming soon to %@!",
            comment: "Title text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        public static let unsupportedCountryDescription = NSLocalizedString(
            "Every country has different rules on how to buy and sell cryptocurrencies. Keep your eyes peeled, we’ll let you know as soon as we launch in %@!",
            comment: "Description text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        public static let unsupportedStateDescription = NSLocalizedString(
            "Every state has different rules on how to buy and sell cryptocurrencies. Keep your eyes peeled, we’ll let you know as soon as we launch in %@!",
            comment: "Description text displayed when the selected country by the user is not supported for crypto-to-crypto exchange"
        )
        public static let messageMeWhenAvailable = NSLocalizedString(
            "Message Me When Available",
            comment: "Text displayed on a button when the user wishes to be notified when crypto-to-crypto exchange is available in their country."
        )
        public static let yourHomeAddress = NSLocalizedString(
            "Your Home Address",
            comment: "Text displayed on the search bar when adding an address during KYC."
        )
        public static let whichDocumentAreYouUsing = NSLocalizedString(
            "Which document are you using?",
            comment: ""
        )
        public static let passport = NSLocalizedString(
            "Valid Passport",
            comment: "The title of the UIAlertAction for the passport option."
        )
        public static let driversLicense = NSLocalizedString(
            "Driver's License",
            comment: "The title of the UIAlertAction for the driver's license option."
        )
        public static let nationalIdentityCard = NSLocalizedString(
            "National ID Card",
            comment: "The title of the UIAlertAction for the national identity card option."
        )
        public static let residencePermit = NSLocalizedString(
            "Residence Card",
            comment: "The title of the UIAlertAction for the residence permit option."
        )
        public static let documentsNeededSummary = NSLocalizedString(
            "Unfortunately we're having trouble verifying your identity, and we need you to resubmit your verification information.",
            comment: "The main message shown in the Documents Needed screen."
        )
        public static let reasonsTitle = NSLocalizedString(
            "Main reasons for this to happen:",
            comment: "Title text in the Documents Needed screen preceding the list of reasons a user would need to resubmit their documents"
        )
        public static let reasonsDescription = NSLocalizedString(
            "The required photos are missing.\n\nThe document you submitted is incorrect.\n\nWe were unable to read the images you submitted due to image quality. ",
            comment: "Description text in the Documents Needed screen preceding the list of reasons a user would need to resubmit their documents"
        )
        public static let submittingInformation = NSLocalizedString(
            "Submitting information...",
            comment: "Text prompt to the user when the client is submitting the identity documents to Blockchain's servers."
        )
        public static let emailAddressAlreadyInUse = NSLocalizedString(
            "This email address has already been used to verify an existing wallet.",
            comment: "The error message when a user attempts to start KYC using an existing email address."
        )
        public static let failedToSendVerificationEmail = NSLocalizedString(
            "Failed to send verification email. Please try again.",
            comment: "The error message shown when the user tries to verify their email but the server failed to send the verification email."
        )
        public static let whyDoWeNeedThis = NSLocalizedString(
            "Why do we need this?",
            comment: "Header text for an a page in the KYC flow where we justify why a certain piece of information is being collected."
        )
        public static let enterEmailExplanation = NSLocalizedString(
            "We need to verify your email address as an added layer of security.",
            comment: "Text explaning to the user why we are collecting their email address."
        )
        public static let checkYourInbox = NSLocalizedString(
            "Check your inbox.",
            comment: "Header text telling the user to check their mail inbox to verify their email"
        )
        public static let confirmEmailExplanation = NSLocalizedString(
            "We just sent you an email with further instructions.",
            comment: "Text telling the user to check their mail inbox to verify their email."
        )
        public static let didntGetTheEmail = NSLocalizedString(
            "Didn't get the email?",
            comment: "Text asking if the user didn't get the verification email."
        )
        public static let sendAgain = NSLocalizedString(
            "Send again",
            comment: "Text asking if the user didn't get the verification email."
        )
        public static let emailSent = NSLocalizedString(
            "Email sent!",
            comment: "Text displayed when the email verification has successfully been sent."
        )
        public static let freeCrypto = NSLocalizedString(
            "Get Free Crypto",
            comment: "Headline displayed on a KYC Tier 2 Cell"
        )
        public static let unlock = NSLocalizedString(
            "Unlock",
            comment: "Prompt to complete a verification tier"
        )
        public static let tierZeroVerification = NSLocalizedString(
            "Tier zero",
            comment: "Tier 0 Verification"
        )
        public static let tierOneVerification = NSLocalizedString(
            "Silver Level",
            comment: "Tier 1 Verification"
        )
        public static let tierTwoVerification = NSLocalizedString(
            "Gold Level",
            comment: "Tier 2 Verification"
        )
        public static let annualSwapLimit = NSLocalizedString(
            "Annual Swap Limit",
            comment: "Annual Swap Limit"
        )
        public static let dailySwapLimit = NSLocalizedString(
            "Daily Swap and Buy Limit",
            comment: "Daily Swap and Buy Limit"
        )
        public static let takesThreeMinutes = NSLocalizedString(
            "Takes 3 min",
            comment: "Duration for Tier 1 application"
        )
        public static let takesTenMinutes = NSLocalizedString(
            "Takes 10 min",
            comment: "Duration for Tier 2 application"
        )
        public static let swapNow = NSLocalizedString("Swap Now", comment: "Swap Now")
        public static let accountLimits = NSLocalizedString(
            "Account Limits",
            comment: "Text shown to represent the level of access a user has to Swap/Buy features."
        )
        public static let swapTagline = NSLocalizedString(
            "Trading your crypto doesn't mean trading away control.",
            comment: "The tagline describing what Swap is"
        )
        public static let swapStatusInReview = NSLocalizedString(
            "In Review",
            comment: "Swap status is in review"
        )
        public static let swapStatusInReviewCTA = NSLocalizedString(
            "In Review - Need More Info",
            comment: "Swap status is in review but we require more info from the user."
        )
        public static let swapStatusUnderReview = NSLocalizedString(
            "Under Review",
            comment: "Swap status is under review."
        )
        public static let swapStatusApproved = NSLocalizedString(
            "Approved!",
            comment: "Swap status is approved."
        )
        public static let swapAnnouncement = NSLocalizedString(
            "Swap by Blockchain enables you to trade crypto with best prices, and quick settlement, all while maintaining full control of your funds.",
            comment: "The announcement and description describing what Swap is."
        )
        public static let swapLimitDescription = NSLocalizedString(
            "Your Swap Limit is the maximum amount of crypto you can trade.",
            comment: "A description of what the user's swap limit is."
        )
        public static let swapUnavailable = NSLocalizedString(
            "Swap Currently Unavailable",
            comment: "Swap Currently Unavailable"
        )
        public static let swapUnavailableDescription = NSLocalizedString(
            "We had trouble approving your identity. Your Swap feature has been disabled at this time.",
            comment: "A description as to why Swap has been disabled"
        )
        public static let available = NSLocalizedString(
            "Available",
            comment: "Available"
        )
        public static let availableToday = NSLocalizedString(
            "Available Today",
            comment: "Available Today"
        )
        public static let tierTwoVerificationIsBeingReviewed = NSLocalizedString(
            "Your Gold level verification is currently being reviewed by a Blockchain Support Member.",
            comment: "The Tiers overview screen when the user is approved for Tier 1 but they are in review for Tier 2"
        )
        public static let tierOneRequirements = NSLocalizedString(
            "Requires Email, Name, Date of Birth and Address",
            comment: "A descriptions of the requirements to complete Tier 1 verification"
        )
        // TODO: how should we handle conditional strings? What if the mobile requirement gets added back?
        public static let tierTwoRequirements = NSLocalizedString(
            "Requires Silver level, Govt. ID and a Selfie",
            comment: "A descriptions of the requirements to complete Tier 2 verification"
        )
        public static let notNow = NSLocalizedString(
            "Not now",
            comment: "Text displayed when the user does not want to continue with tier 2 KYC."
        )
        public static let moreInfoNeededHeaderText = NSLocalizedString(
            "We Need Some More Information to Complete Your Profile",
            comment: "Header text when more information is needed from the user for KYCing"
        )
        public static let moreInfoNeededSubHeaderText = NSLocalizedString(
            "You’ll need to verify your phone number, provide a government issued ID and a Selfie.",
            comment: "Header text when more information is needed from the user for KYCing"
        )
        public static let openEmailApp = NSLocalizedString(
            "Open Email App",
            comment: "CTA for when the user should open the email app to continue email verification."
        )
        public static let submit = NSLocalizedString(
            "Submit",
            comment: "Text displayed on the CTA when submitting KYC information."
        )
        public static let termsOfServiceAndPrivacyPolicyNoticeAddress = NSLocalizedString(
            "By tapping Submit, you agree to Blockchain’s %@ & %@",
            comment: "Text displayed to the user notifying them that they implicitly agree to Blockchain’s terms of service and privacy policy when they start the KYC process."
        )
        public static let completingTierTwoAutoEligible = NSLocalizedString(
            "By completing the Gold Level requirements you are automatically eligible for our airdrop program.",
            comment: "Description of what the user gets out of completing Tier 2 verification that is seen at the bottom of the Tiers screen. This particular description is when the user has been Tier 1 verified."
        )
        public static let needSomeHelp = NSLocalizedString("Need some help?", comment: "Need some help?")
        public static let helpGuides = NSLocalizedString(
            "Our Blockchain Support Team has written Help Guides explaining why we need to verify your identity",
            comment: "Description shown in modal that is presented when tapping the question mark in KYC."
        )
        public static let readNow = NSLocalizedString("Read Now", comment: "Read Now")
        public static let enableCamera = NSLocalizedString(
            "Also, enable your camera!",
            comment: "Requesting user to enable their camera"
        )
        public static let enableCameraDescription = NSLocalizedString(
            "Please allow your Blockchain App access your camera to upload your ID and take a Selfie.",
            comment: "Description as to why the user should permit camera access"
        )
        public static let enableMicrophoneDescription = NSLocalizedString(
            "Please allow your Blockchain app access to your microphone. This is an optional request designed to enhance user security while performing ID verification",
            comment: "Description as to why the user should permit microphone access"
        )
        public static let isCountrySupportedHeader = NSLocalizedString(
            "Is my country supported?",
            comment: "Header for text notifying the user that maybe not all countries are supported for airdrop."
        )
        public static let isCountrySupportedDescription1 = NSLocalizedString(
            "Not all countries are supported at this time. Check our up to date",
            comment: "Description for text notifying the user that maybe not all countries are supported for airdrop."
        )
        public static let isCountrySupportedDescription2 = NSLocalizedString(
            "list of countries",
            comment: "Description for text notifying the user that maybe not all countries are supported for airdrop."
        )
        public static let isCountrySupportedDescription3 = NSLocalizedString(
            "before proceeding.",
            comment: "Description for text notifying the user that maybe not all countries are supported for airdrop."
        )
        public static let allowCameraAccess = NSLocalizedString(
            "Allow camera access?",
            comment: "Headline in alert asking the user to allow camera access."
        )
        public static let allowMicrophoneAccess = NSLocalizedString(
            "Allow microphone access?",
            comment: "Headline in alert asking the user to allow microphone access."
        )
        public static let streetLine = NSLocalizedString("Street line", comment: "Street line")
        public static let addressLine = NSLocalizedString("Address line", comment: "Address line")
        public static let city = NSLocalizedString("City", comment: "city")
        public static let cityTownVillage = NSLocalizedString("City / Town / Village", comment: "City / Town / Village")
        public static let zipCode = NSLocalizedString("Zip Code", comment: "zip code")
        public static let required = NSLocalizedString("Required", comment: "required")
        public static let state = NSLocalizedString("State", comment: "state")
        public static let stateRegionProvinceCountry = NSLocalizedString("State / Region / Province / Country", comment: "State / Region / Province / Country")
        public static let postalCode = NSLocalizedString("Postal Code", comment: "postal code")

        public enum Errors {
            public static let genericErrorMessage = NSLocalizedString("Please check the information you provided and try again.", comment: "A message shown when something goes wrong on the backend, normally address validation.")
            public static let cannotFetchUserAlertTitle = NSLocalizedString(
                "Failed to get user",
                comment: "The title for an alert shown if the logged in user cannot be fetched."
            )
        }
    }
}
