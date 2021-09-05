// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// An `AssetAccount` that only supports a single address (e.g. XLM)
public protocol SingleAddressAssetAccount: AssetAccount {
    associatedtype Address: AssetAddress

    var address: Address { get }
}
