// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct BitcoinHDAssetAccount: HDAddressAssetAccount {

    // MARK: - HDAddressAssetAccount

    public typealias Address = BitcoinAssetAddress

    public let xpub: String

    public var currentAddress: Address {
        BitcoinAssetAddress(
            isImported: false,
            publicKey: ""
        )
    }

    public var currentReceiveIndex: Int

    // MARK: - AssetAccount

    public var accountAddress: String {
        currentAddress.publicKey
    }

    public var name: String

    public var description: String

    public var walletIndex: Int
}
