// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import RxSwift

@available(*, deprecated, message: "This has been replaced by new Combine PasswordValidatorAPI as part of SSO Account Recovery Development")
public protocol NewPasswordValidating: TextValidating {
    var score: Observable<PasswordValidationScore> { get }
}
