// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A URI scheme that conforms to SEP 0007 (https://github.com/stellar/stellar-protocol/blob/master/ecosystem/sep-0007.md)
public protocol SEP7URI: CryptoAssetQRMetadata {
    init?(url: URL)
}
