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
        case .coin(let model):
            switch model.code {
            case let code where NonCustodialCoinCode.allCases.map(\.rawValue).contains(code):
                factory = { () -> CryptoReceiveAddressFactory in resolve(tag: asset.typeTag) }()
            default:
                factory = PlainCryptoReceiveAddressFactory()
            }
        case .erc20:
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
        guard let regex = try? NSRegularExpression(pattern: "[a-zA-Z0-9]{15,}") else {
            return .failure(.invalidAddress)
        }
        let range = NSRange(location: 0, length: address.utf16.count)
        let firstMatch = regex.firstMatch(in: address, options: [], range: range)
        guard firstMatch != nil else {
            return .failure(.invalidAddress)
        }
        return .success(PlainCryptoReceiveAddress(address: address, asset: asset, label: label))
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
