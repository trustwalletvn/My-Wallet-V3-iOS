// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Localization
import PlatformKit
import UIKit

struct KYCInformationViewModel {
    let image: UIImage?
    let title: String?
    let subtitle: String?
    let description: String?
    let buttonTitle: String?
}

struct KYCInformationViewConfig {
    let titleColor: UIColor
    let isPrimaryButtonEnabled: Bool
    let imageTintColor: UIColor?
}

extension KYCInformationViewModel {
    static func createForUnsupportedCountry(_ country: CountryData) -> KYCInformationViewModel {
        KYCInformationViewModel(
            image: UIImage(named: "Welcome", in: .featureKYCUI, compatibleWith: nil),
            title: String(format: LocalizationConstants.KYC.comingSoonToX, country.name),
            subtitle: nil,
            description: String(format: LocalizationConstants.KYC.unsupportedCountryDescription, country.name),
            buttonTitle: LocalizationConstants.KYC.messageMeWhenAvailable
        )
    }

    static func createForUnsupportedState(_ state: KYCState) -> KYCInformationViewModel {
        KYCInformationViewModel(
            image: UIImage(named: "Welcome", in: .featureKYCUI, compatibleWith: nil),
            title: String(format: LocalizationConstants.KYC.comingSoonToX, state.name),
            subtitle: nil,
            description: String(format: LocalizationConstants.KYC.unsupportedStateDescription, state.name),
            buttonTitle: LocalizationConstants.KYC.messageMeWhenAvailable
        )
    }

    static func create(
        for accountStatus: KYC.AccountStatus,
        isReceivingAirdrop: Bool = false
    ) -> KYCInformationViewModel {
        switch accountStatus {
        case .approved:
            return KYCInformationViewModel(
                image: UIImage(named: "AccountApproved", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.accountApproved,
                subtitle: nil,
                description: LocalizationConstants.KYC.accountApprovedDescription,
                buttonTitle: LocalizationConstants.KYC.getStarted
            )
        case .expired, .failed:
            return KYCInformationViewModel(
                image: UIImage(named: "AccountFailed", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.verificationFailed,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationFailedDescription,
                buttonTitle: nil
            )
        case .pending:
            return createViewModelForPendingStatus(isReceivingAirdrop: isReceivingAirdrop)
        case .underReview:
            return KYCInformationViewModel(
                image: UIImage(named: "AccountInReview", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.verificationUnderReview,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationUnderReviewDescription,
                buttonTitle: nil
            )
        case .none:
            return KYCInformationViewModel(
                image: nil,
                title: nil,
                subtitle: nil,
                description: nil,
                buttonTitle: nil
            )
        }
    }

    // MARK: - Private

    private static func createViewModelForPendingStatus(isReceivingAirdrop: Bool) -> KYCInformationViewModel {
        if isReceivingAirdrop {
            return KYCInformationViewModel(
                image: UIImage(named: "Icon-Verified-Large", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.verificationInProgress,
                subtitle: nil,
                description: LocalizationConstants.KYC.verificationInProgressDescriptionAirdrop,
                buttonTitle: LocalizationConstants.KYC.notifyMe
            )
        } else {
            return KYCInformationViewModel(
                image: UIImage(named: "AccountInReview", in: .featureKYCUI, compatibleWith: nil),
                title: LocalizationConstants.KYC.verificationInProgress,
                subtitle: LocalizationConstants.KYC.whatHappensNext,
                description: LocalizationConstants.KYC.verificationInProgressDescription,
                buttonTitle: LocalizationConstants.KYC.notifyMe
            )
        }
    }
}

extension KYCInformationViewConfig {
    static let defaultConfig = KYCInformationViewConfig(
        titleColor: UIColor.gray5,
        isPrimaryButtonEnabled: false,
        imageTintColor: nil
    )

    static func create(for accountStatus: KYC.AccountStatus, isReceivingAirdrop: Bool = false) -> KYCInformationViewConfig {
        let titleColor: UIColor
        let isPrimaryButtonEnabled: Bool
        var tintColor: UIColor?

        switch accountStatus {
        case .approved:
            titleColor = UIColor.green
            isPrimaryButtonEnabled = true
        case .failed, .expired, .none:
            titleColor = UIColor.error
            isPrimaryButtonEnabled = false
        case .pending:
            titleColor = isReceivingAirdrop ? UIColor.green : UIColor.pending
            isPrimaryButtonEnabled = !UIApplication.shared.isRegisteredForRemoteNotifications
            tintColor = isReceivingAirdrop ? UIColor.brandSecondary : nil
        case .underReview:
            titleColor = .orange
            isPrimaryButtonEnabled = false
        }
        return KYCInformationViewConfig(
            titleColor: titleColor,
            isPrimaryButtonEnabled: isPrimaryButtonEnabled,
            imageTintColor: tintColor
        )
    }
}
