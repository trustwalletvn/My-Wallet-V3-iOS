// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit

class UserMock: User {
    var email = Email(address: "", verified: false)
    var personalDetails = PersonalDetails(id: nil, first: nil, last: nil, birthday: nil)
    var address: UserAddress?
}
