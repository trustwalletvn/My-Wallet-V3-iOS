// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public typealias Password = String

public protocol PasswordAccessAPI {
    var password: Maybe<Password> { get }
}
