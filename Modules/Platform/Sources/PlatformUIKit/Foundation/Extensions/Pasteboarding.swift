// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol Pasteboarding: AnyObject {
    var string: String? { get set }
}

extension UIPasteboard: Pasteboarding {}
