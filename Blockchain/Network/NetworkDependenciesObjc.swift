// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import NetworkKit

@available(swift, obsoleted: 1, message: "Don't use this. If you're reaching for this you're doing something wrong.")
final class NetworkDependenciesObjc: NSObject {
    @objc static var session: URLSession { resolve() }
}
