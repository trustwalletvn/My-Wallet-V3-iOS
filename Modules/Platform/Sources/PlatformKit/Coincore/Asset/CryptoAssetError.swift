// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum CryptoAssetError: Error {
    case noDefaultAccount
    case addressParseFailure
    case failedToLoadDefaultAccount(Error)
}
