// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct DomainResolutionRequest: Encodable {
    let currency: String
    let name: String
}
