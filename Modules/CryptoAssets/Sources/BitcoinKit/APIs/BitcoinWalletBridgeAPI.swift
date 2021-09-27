// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import PlatformKit
import RxSwift

public struct PayloadBitcoinWalletAccountV4: Decodable {
    public struct Derivation: Decodable {
        public struct Cache: Decodable {
            public let receiveAccount: String
            public let changeAccount: String
        }

        public struct Label: Decodable {
            public let index: Int
            public let label: String
        }

        public let address_labels: [Label]?
        public let cache: Cache
        public let purpose: Int
        public let type: DerivationType
        public let xpub: String
        public let xpriv: String
    }

    public let label: String
    public let archived: Bool
    public let default_derivation: String
    public let derivations: [Derivation]
}

public struct PayloadBitcoinWalletAccountV3: Codable {

    public struct Cache: Codable {
        public let receiveAccount: String
        public let changeAccount: String
    }

    public struct Label: Codable {
        public let index: Int
        public let label: String
    }

    public let label: String
    public let archived: Bool
    public let xpriv: String
    public let xpub: String
    public let address_labels: [Label]?
    public let cache: Cache
}

public protocol BitcoinWalletBridgeAPI: AnyObject {

    // MARK: - Wallet Account

    var defaultWallet: Single<BitcoinWalletAccount> { get }

    var wallets: Single<[BitcoinWalletAccount]> { get }

    func memo(for transactionHash: String) -> Single<String?>

    func updateMemo(for transactionHash: String, memo: String?) -> Completable

    func receiveAddress(forXPub xpub: String) -> Single<String>

    func walletIndex(for receiveAddress: String) -> Single<Int32>

    func update(accountIndex: Int, label: String) -> Completable
}
