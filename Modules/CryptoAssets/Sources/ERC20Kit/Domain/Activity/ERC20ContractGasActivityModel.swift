// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import EthereumKit
import PlatformKit

public struct ERC20ContractGasActivityModel {

    public let cryptoCurrency: CryptoCurrency
    public let cryptoValue: CryptoValue?
    public let to: EthereumAddress?

    public init?(details: EthereumActivityItemEventDetails) {
        guard let cryptoCurrency = ERC20ContractGasActivityModel.token(address: details.to) else {
            return nil
        }
        self.cryptoCurrency = cryptoCurrency
        switch ERC20Function(data: details.data) {
        case .transfer(to: let address, amount: let hexAmount):
            cryptoValue = ERC20ContractGasActivityModel.gasCryptoValue(hexAmount: hexAmount, cryptoCurrency: cryptoCurrency)
            to = EthereumAddress(address: address)!
        case nil:
            cryptoValue = nil
            to = nil
        }
    }

    private static func gasCryptoValue(hexAmount: String?, cryptoCurrency: CryptoCurrency) -> CryptoValue? {
        guard
            let hexAmount = hexAmount,
            let decimalAmount = BigInt(hexAmount, radix: 16)
        else { return nil }
        return CryptoValue.create(minor: decimalAmount, currency: cryptoCurrency)
    }

    private static func token(address: EthereumAddress) -> CryptoCurrency? {
        let service: EnabledCurrenciesServiceAPI = resolve()
        let knownERC20: [ERC20AssetModel] = service.allEnabledCryptoCurrencies
            .compactMap { currency in
                switch currency {
                case .erc20(let model):
                    return model
                default:
                    return nil
                }
            }
        let publicKey = address.publicKey.lowercased()
        for token in knownERC20 {
            if publicKey.compare(token.contractAddress.publicKey, options: .caseInsensitive) == .orderedSame {
                return token.cryptoCurrency
            }
        }
        return nil
    }
}
