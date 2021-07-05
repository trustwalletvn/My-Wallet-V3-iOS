// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public enum CryptoReceiveAddressFactoryError: Error {
    case invalidAddress
    case unsupportedAsset
}

/// Resolve this protocol with a `CryptoCurrency.typeTag` to receive a factory that builds `CryptoReceiveAddress`.
public protocol CryptoReceiveAddressFactory {

    typealias TxCompleted = (TransactionResult) -> Completable

    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError>
}

public final class CryptoReceiveAddressFactoryService {

    public func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping (TransactionResult) -> Completable
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        let factory: CryptoReceiveAddressFactory
        switch asset {
        case .other:
            factory = PlainCryptoReceiveAddressFactory()
        default:
            factory = { () -> CryptoReceiveAddressFactory in resolve(tag: asset.typeTag) }()
        }
        return factory.makeExternalAssetAddress(
            asset: asset,
            address: address,
            label: label,
            onTxCompleted: onTxCompleted
        )
    }
}

/// A `CryptoReceiveAddressFactory` that doesn't know how to validate the asset/address and assumes it is correct.
final class PlainCryptoReceiveAddressFactory: CryptoReceiveAddressFactory {
    func makeExternalAssetAddress(
        asset: CryptoCurrency,
        address: String,
        label: String,
        onTxCompleted: @escaping TxCompleted
    ) -> Result<CryptoReceiveAddress, CryptoReceiveAddressFactoryError> {
        .success(PlainCryptoReceiveAddress(address: address, asset: asset, label: label))
    }
}

/// A `CryptoReceiveAddress & CryptoAssetQRMetadataProviding` that doesn't know how to validate the asset/address and assumes it is correct.
struct PlainCryptoReceiveAddress: CryptoReceiveAddress, CryptoAssetQRMetadataProviding {
    let address: String
    let asset: CryptoCurrency
    let label: String
    var metadata: CryptoAssetQRMetadata {
        PlainCryptoAssetQRMetadata(address: address, cryptoCurrency: asset)
    }
    init(address: String, asset: CryptoCurrency, label: String) {
        self.address = address
        self.asset = asset
        self.label = label
    }
}

/// A `CryptoAssetQRMetadata` that doesn't know how to validate the asset/address and assumes it is correct.
struct PlainCryptoAssetQRMetadata: CryptoAssetQRMetadata {
    let address: String
    let amount: String? = nil
    let cryptoCurrency: CryptoCurrency
    let includeScheme: Bool = false
    var absoluteString: String {
        address
    }
}
