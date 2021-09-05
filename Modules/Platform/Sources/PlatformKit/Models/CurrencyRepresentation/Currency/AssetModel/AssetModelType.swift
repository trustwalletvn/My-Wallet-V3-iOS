// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Supported types for an `AssetModel`.
public enum AssetModelType: Hashable {
    case coin
    case erc20
    case fiat
}
