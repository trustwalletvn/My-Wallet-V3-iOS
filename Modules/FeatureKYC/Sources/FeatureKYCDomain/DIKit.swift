// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureKYCDomain Module

    public static var featureKYCDomain = module {

        single { KYCSettings() as KYCSettingsAPI }

        factory { KYCStatusChecker() as KYCStatusChecking }

        factory { EmailVerificationService(apiClient: DIKit.resolve()) as EmailVerificationServiceAPI }
    }
}
