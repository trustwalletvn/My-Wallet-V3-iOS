// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import RxSwift

@available(*, deprecated, message: "This has been replaced by new Combine SeedPhraseValidatorAPI as part of SSO Account Recovery Development")
public protocol MnemonicValidating: TextValidating {
    var score: Observable<MnemonicValidationScore> { get }
}
