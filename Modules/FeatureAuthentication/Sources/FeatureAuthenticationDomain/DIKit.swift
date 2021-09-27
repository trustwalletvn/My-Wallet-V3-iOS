// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

extension DependencyContainer {

    // MARK: - FeatureAuthenticationDomain Module

    public static var featureAuthenticationDomain = module {

        // MARK: - Services

        single {
            PasswordValidator() as PasswordValidatorAPI
        }

        single {
            SeedPhraseValidator() as SeedPhraseValidatorAPI
        }
    }
}
