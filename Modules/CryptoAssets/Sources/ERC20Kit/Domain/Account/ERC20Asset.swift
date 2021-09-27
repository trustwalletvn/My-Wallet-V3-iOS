// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CombineExt
import DIKit
import EthereumKit
import PlatformKit
import RxSwift
import ToolKit

final class ERC20Asset: CryptoAsset {

    // MARK: - Properties

    let asset: CryptoCurrency

    var canTransactToCustodial: AnyPublisher<Bool, Never> {
        cryptoAssetRepository.canTransactToCustodial
    }

    // MARK: - Private properties

    var defaultAccount: AnyPublisher<SingleAccount, CryptoAssetError> {
        walletAccountBridge.wallets
            .asPublisher()
            .map(\.first)
            .mapError(CryptoAssetError.failedToLoadDefaultAccount)
            .flatMap { wallet -> AnyPublisher<EthereumWalletAccount, CryptoAssetError> in
                guard let wallet = wallet else {
                    return .failure(.noDefaultAccount)
                }
                return .just(wallet)
            }
            .map { [erc20Token] wallet -> SingleAccount in
                ERC20CryptoAccount(
                    publicKey: wallet.publicKey,
                    erc20Token: erc20Token
                )
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private lazy var cryptoAssetRepository: CryptoAssetRepositoryAPI = {
        CryptoAssetRepository(
            asset: asset,
            errorRecorder: errorRecorder,
            kycTiersService: kycTiersService,
            defaultAccountProvider: { [defaultAccount] in
                defaultAccount
            },
            exchangeAccountsProvider: exchangeAccountProvider,
            addressFactory: addressFactory
        )
    }()

    private let addressFactory: ERC20ExternalAssetAddressFactory
    private let erc20Token: ERC20AssetModel
    private let kycTiersService: KYCTiersServiceAPI
    private let exchangeAccountProvider: ExchangeAccountsProviderAPI
    private let walletAccountBridge: EthereumWalletAccountBridgeAPI
    private let errorRecorder: ErrorRecording

    // MARK: - Setup

    init(
        erc20Token: ERC20AssetModel,
        walletAccountBridge: EthereumWalletAccountBridgeAPI = resolve(),
        errorRecorder: ErrorRecording = resolve(),
        exchangeAccountProvider: ExchangeAccountsProviderAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        addressFactory: ERC20ExternalAssetAddressFactory = .init()
    ) {
        asset = erc20Token.cryptoCurrency
        self.addressFactory = addressFactory
        self.erc20Token = erc20Token
        self.walletAccountBridge = walletAccountBridge
        self.errorRecorder = errorRecorder
        self.exchangeAccountProvider = exchangeAccountProvider
        self.kycTiersService = kycTiersService
    }

    // MARK: - Asset

    func initialize() -> AnyPublisher<Void, AssetError> {
        .empty()
    }

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never> {
        cryptoAssetRepository.accountGroup(filter: filter)
    }

    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never> {
        cryptoAssetRepository.parse(address: address)
    }
}
