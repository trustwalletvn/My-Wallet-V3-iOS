// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Zxcvbn

public protocol PasswordValidatorAPI {
    func validate(password: String) -> AnyPublisher<PasswordValidationScore, Never>
}

public final class PasswordValidator: PasswordValidatorAPI {

    // MARK: - Properties

    private let validationProvider: DBZxcvbn

    // MARK: - Setup

    public init(validationProvider: DBZxcvbn = DBZxcvbn()) {
        self.validationProvider = validationProvider
    }

    // MARK: - API

    public func validate(password: String) -> AnyPublisher<PasswordValidationScore, Never> {
        let validationProvider = self.validationProvider
        return Deferred {
            Future { [validationProvider] promise in
                validationProvider.passwordStrength(password)
                    .map { result in
                        promise(.success(PasswordValidationScore(
                            zxcvbnScore: result.score,
                            password: password
                        )))
                    }
            }
        }
        .eraseToAnyPublisher()
    }
}
