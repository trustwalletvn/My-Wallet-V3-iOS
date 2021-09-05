// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol ContextProviderAPI {
    var context: Context { get }
    var anonymousId: String? { get }
}
