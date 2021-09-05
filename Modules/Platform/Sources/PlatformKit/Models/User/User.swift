// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol User {
    var email: Email { get }
    var personalDetails: PersonalDetails { get }
    var address: UserAddress? { get }
}
