// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum PlatformKitError: Error {
    case `default`
    case illegalArgument
    case illegalStateException(message: String)
}
