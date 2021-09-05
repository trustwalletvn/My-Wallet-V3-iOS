// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

/// Conform to this protocol if your service should be able to validate addresses
/// prior to sending a payload.
public protocol AccountValidationAPI {
    typealias AccountID = String

    // Checks if address is valid
    static func validate(accountID: AccountID) -> Single<Bool>
}
