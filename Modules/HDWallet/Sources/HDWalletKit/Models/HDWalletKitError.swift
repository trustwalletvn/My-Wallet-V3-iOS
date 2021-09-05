// Copyright © Blockchain Luxembourg S.A. All rights reserved.

enum HDWalletKitError: Error {
    case unknown
    case libWallyError(Error)
}
