// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension URLRequest {
    init(url: URL, method: HTTPMethod) {
        self.init(url: url)
        httpMethod = method.rawValue
    }
}
