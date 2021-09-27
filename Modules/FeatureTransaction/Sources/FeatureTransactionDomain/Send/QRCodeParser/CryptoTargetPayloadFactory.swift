// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

final class CryptoTargetPayloadFactory: CryptoTargetPayloadFactoryAPI {

    // MARK: - Enums

    private enum CryptoTargetPayloadError: Error {
        case invalidStringData
    }

    // MARK: - Private Properties

    private let receiveAddressService: CryptoReceiveAddressFactoryService

    // MARK: - Init

    init(receiveAddressService: CryptoReceiveAddressFactoryService = resolve()) {
        self.receiveAddressService = receiveAddressService
    }

    // MARK: - CryptoTargetPayloadFactoryAPI

    func create(fromString string: String?, asset: CryptoCurrency) -> Single<CryptoTargetQRCodeParser.Target> {
        guard let data = string else {
            return .error(CryptoTargetPayloadError.invalidStringData)
        }
        let metadata = makeCryptoQRMetaData(fromString: data, asset: asset)
        return BitPayInvoiceTarget
            // Check if the data is a BitPay payload.
            .isBitPay(data)
            // Check if the asset is a supported asset for BitPay.
            .andThen(BitPayInvoiceTarget.isSupportedAsset(asset))
            // Return the BitPay data
            .andThen(Single.just(.bitpay(data)))
            .catchError { error in
                guard let bitpayError = error as? BitPayError else { return .error(error) }
                switch bitpayError {
                // If the BitPay URL is valid but
                // is invalid for either BTC or BCH
                // we throw an error.
                case .unsupportedCurrencyType,
                     .invalidBitcoinURL,
                     .invalidBitcoinCashURL,
                     .invoiceError:
                    return .error(bitpayError)
                // If the BitPay URL is invalid,
                // we return the data, as it's likely a regular
                // receive address.
                case .invalidBitPayURL:
                    return metadata
                }
            }
    }

    // MARK: - Private Functions

    private func makeCryptoQRMetaData(fromString string: String, asset: CryptoCurrency) -> Single<CryptoTargetQRCodeParser.Target> {
        receiveAddressService
            .makeExternalAssetAddress(
                asset: asset,
                address: string,
                label: string,
                onTxCompleted: { _ in .empty() }
            )
            .map(CryptoTargetQRCodeParser.Target.address)
            .replaceError(with: CryptoTargetPayloadError.invalidStringData)
            .single
    }
}
