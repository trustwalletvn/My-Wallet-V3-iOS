// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol KeyPair {
    associatedtype PrivateKey

    var privateKey: PrivateKey { get }
}
