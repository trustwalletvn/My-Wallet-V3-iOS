// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain
import NetworkKit
import ToolKit

public protocol ERC20AssetFactoryAPI {
    func erc20Asset(erc20AssetModel: ERC20AssetModel) -> CryptoAsset
}

extension DependencyContainer {

    // MARK: - PlatformKit Module

    public static var platformKit = module {

        // MARK: - Today Extension

        single { PortfolioSyncingService() as BalanceSharingSettingsServiceAPI }

        // MARK: - Clients

        factory { SettingsClient() as SettingsClientAPI }

        factory { SwapClient() as SwapClientAPI }

        factory { GeneralInformationClient() as GeneralInformationClientAPI }

        factory { PriceClient() as PriceClientAPI }

        factory { UpdateWalletInformationClient() as UpdateWalletInformationClientAPI }

        factory { JWTClient() as JWTClientAPI }

        factory { KYCClient() as KYCClientAPI }

        factory { UserCreationClient() as UserCreationClientAPI }

        factory { NabuAuthenticationClient() as NabuAuthenticationClientAPI }

        factory { SupportedAssetsRemoteService() as SupportedAssetsRemoteServiceAPI }

        factory { SupportedAssetsClient() as SupportedAssetsClientAPI }

        // MARK: Exchange

        factory { ExchangeAccountsClient() as ExchangeAccountsClientAPI }

        // MARK: CustodialClient

        factory { CustodialClient() as CustodialPaymentAccountClientAPI }

        factory { CustodialClient() as CustodialPendingDepositClientAPI }

        factory { CustodialClient() as TradingBalanceClientAPI }

        // MARK: - Authentication

        single { NabuTokenStore() }

        single { NabuAuthenticationExecutor() as NabuAuthenticationExecutorAPI }

        // swiftlint:disable opening_brace
        factory { () -> NabuAuthenticationExecutorProvider in
            { () -> NabuAuthenticationExecutorAPI in
                DIKit.resolve()
            }
        }
        // swiftlint:enable opening_brace

        factory { NabuAuthenticator() as AuthenticatorAPI }

        factory { JWTService() as JWTServiceAPI }

        // MARK: - Wallet

        factory { WalletNabuSynchronizerService() as WalletNabuSynchronizerServiceAPI }

        factory { () -> WalletRepositoryAPI in
            let walletRepositoryProvider: WalletRepositoryProvider = DIKit.resolve()
            return walletRepositoryProvider.repository as WalletRepositoryAPI
        }

        factory { MnemonicComponentsProvider() as MnemonicComponentsProviding }

        factory { () -> CredentialsRepositoryAPI in
            let repository: WalletRepositoryAPI = DIKit.resolve()
            return repository as CredentialsRepositoryAPI
        }

        factory { () -> NabuOfflineTokenRepositoryAPI in
            let repository: WalletRepositoryAPI = DIKit.resolve()
            return repository as NabuOfflineTokenRepositoryAPI
        }

        factory { () -> NabuAuthenticationExecutor.CredentialsRepository in
            let repository: WalletRepositoryAPI = DIKit.resolve()
            return repository as NabuAuthenticationExecutor.CredentialsRepository
        }

        // MARK: - Secure Channel

        single { SecureChannelService() as SecureChannelAPI }

        single { BrowserIdentityService() }

        single { SecureChannelClient() as SecureChannelClientAPI }

        factory { SecureChannelMessageService() }

        // MARK: - Services

        single { EnabledCurrenciesService() as EnabledCurrenciesServiceAPI }

        single { KYCTiersService() as KYCTiersServiceAPI }

        single { NabuUserService() as NabuUserServiceAPI }

        single { GeneralInformationService() as GeneralInformationServiceAPI }

        single { EmailVerificationService() as EmailVerificationServiceAPI }

        factory { SwapActivityService() as SwapActivityServiceAPI }

        single { ExchangeAccountsProvider() as ExchangeAccountsProviderAPI }

        factory { ExchangeAccountStatusService() as ExchangeAccountStatusServiceAPI }

        factory { LinkedBanksFactory() as LinkedBanksFactoryAPI }

        single { () -> CoincoreAPI in
            let provider: EnabledCurrenciesServiceAPI = DIKit.resolve()
            let allEnabledCryptoCurrencies = provider.allEnabledCryptoCurrencies
            let nonCustodialCoinCodes = NonCustodialCoinCode.allCases.map(\.rawValue)

            let nonCustodialAssets = allEnabledCryptoCurrencies
                .filter(\.isCoin)
                .filter { nonCustodialCoinCodes.contains($0.code) }
                .map { cryptoCurrency -> CryptoAsset in
                    let asset: CryptoAsset = DIKit.resolve(tag: cryptoCurrency)
                    return asset
                }
            let custodialAssets = allEnabledCryptoCurrencies
                .filter(\.isCoin)
                .filter { !nonCustodialCoinCodes.contains($0.code) }
                .map { cryptoCurrency -> CryptoAsset in
                    CustodialCryptoAsset(asset: cryptoCurrency)
                }
            let erc20Factory: ERC20AssetFactoryAPI = DIKit.resolve()
            let erc20Assets = allEnabledCryptoCurrencies
                .filter(\.isERC20)
                .compactMap { cryptoCurrency -> ERC20AssetModel? in
                    guard case .erc20(let model) = cryptoCurrency else {
                        return nil
                    }
                    return model
                }
                .compactMap { erc20Factory.erc20Asset(erc20AssetModel: $0) }

            return Coincore(
                cryptoAssets: nonCustodialAssets + custodialAssets + erc20Assets
            )
        }

        factory { SupportedAssetsFilePathProvider() as SupportedAssetsFilePathProviderAPI }

        factory { SupportedAssetsService() as SupportedAssetsServiceAPI }

        single { SupportedAssetsRepository() as SupportedAssetsRepositoryAPI }

        single { FiatPriceService() as FiatPriceServiceAPI }

        single { ReactiveWallet() as ReactiveWalletAPI }

        factory { BlockchainAccountProvider() as BlockchainAccountProviding }

        single { WalletService() as WalletOptionsAPI }

        factory { CustodialPendingDepositService() as CustodialPendingDepositServiceAPI }

        factory { CustodialAddressService() as CustodialAddressServiceAPI }

        factory { () -> MaintenanceServicing in
            let service: WalletOptionsAPI = DIKit.resolve()
            return service
        }

        factory { CredentialsStore() as CredentialsStoreAPI }

        factory { NSUbiquitousKeyValueStore.default as UbiquitousKeyValueStore }

        single { TradingBalanceService() as TradingBalanceServiceAPI }

        factory { PriceService() as PriceServiceAPI }

        factory { CryptoReceiveAddressFactoryService() }

        factory { BlockchainAccountFetcher() as BlockchainAccountFetching }

        // MARK: - Settings

        single { SettingsService() as CompleteSettingsServiceAPI }

        factory { () -> FiatCurrencySettingsServiceAPI in
            let completeSettings: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettings
        }

        factory { () -> EmailSettingsServiceAPI in
            let completeSettings: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettings
        }

        factory { () -> SMSTwoFactorSettingsServiceAPI in
            let completeSettings: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettings
        }

        factory { () -> EmailNotificationSettingsServiceAPI in
            let completeSettings: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettings
        }

        // MARK: - KYC

        factory { KYCTierUpdatePollingService() as KYCTierUpdatePollingServiceAPI }
    }

    // MARK: - BuySellKit Module

    public static var buySellKit = module {

        // MARK: - Clients - General

        factory { APIClient() as SimpleBuyClientAPI }

        factory { () -> SupportedPairsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as SupportedPairsClientAPI
        }

        factory { () -> BeneficiariesClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as BeneficiariesClientAPI
        }

        factory { () -> OrderDetailsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as OrderDetailsClientAPI
        }

        factory { () -> OrderCancellationClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as OrderCancellationClientAPI
        }

        factory { () -> OrderCreationClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as OrderCreationClientAPI
        }

        factory { () -> EligibilityClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as EligibilityClientAPI
        }

        factory { () -> PaymentAccountClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as PaymentAccountClientAPI
        }

        factory { () -> SuggestedAmountsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as SuggestedAmountsClientAPI
        }

        factory { () -> QuoteClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client
        }

        factory { () -> CardOrderConfirmationClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client
        }

        factory { () -> WithdrawalClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as WithdrawalClientAPI
        }

        factory { () -> PaymentEligibleMethodsClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as PaymentEligibleMethodsClientAPI
        }

        factory { () -> LinkedBanksClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as LinkedBanksClientAPI
        }

        factory { () -> OrdersActivityClientAPI in
            let client: SimpleBuyClientAPI = DIKit.resolve()
            return client as OrdersActivityClientAPI
        }

        factory { WithdrawalService() as WithdrawalServiceAPI }

        // MARK: - Clients - Cards

        factory { CardClient() as CardClientAPI }

        factory { EveryPayClient() as EveryPayClientAPI }

        factory { () -> CardListClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardListClientAPI
        }

        factory { () -> CardDeletionClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardDeletionClientAPI
        }

        factory { () -> CardDetailClientAPI in
            let client: CardClientAPI = DIKit.resolve()
            return client as CardDetailClientAPI
        }

        // MARK: - Services - General

        factory { OrdersActivityService() as OrdersActivityServiceAPI }

        factory { OrderConfirmationService() as OrderConfirmationServiceAPI }

        factory { OrderQuoteService() as OrderQuoteServiceAPI }

        factory { EventCache() }

        single { OrdersService() as OrdersServiceAPI }

        factory { PendingOrderDetailsService() as PendingOrderDetailsServiceAPI }

        factory { PendingOrderCompletionService() as PendingOrderCompletionServiceAPI }

        factory { OrderCancellationService() as OrderCancellationServiceAPI }

        factory { OrderCreationService() as OrderCreationServiceAPI }

        factory { PaymentAccountService() as PaymentAccountServiceAPI }

        single { SupportedPairsInteractorService() as SupportedPairsInteractorServiceAPI }

        factory { SupportedPairsService() as SupportedPairsServiceAPI }

        single { EligibilityService() as EligibilityServiceAPI }

        factory { SuggestedAmountsService() as SuggestedAmountsServiceAPI }

        single { LinkedBanksService() as LinkedBanksServiceAPI }

        // MARK: - Services - Payment Methods

        single { BeneficiariesServiceUpdater() as BeneficiariesServiceUpdaterAPI }

        single { BeneficiariesService() as BeneficiariesServiceAPI }

        single { PaymentMethodTypesService() as PaymentMethodTypesServiceAPI }

        single { EligiblePaymentMethodsService() as PaymentMethodsServiceAPI }

        // MARK: - Services - Cards

        factory { CardActivationService() as CardActivationServiceAPI }

        factory { CardUpdateService() as CardUpdateServiceAPI }

        single { CardListService() as CardListServiceAPI }

        factory { CardDeletionService() as PaymentMethodDeletionServiceAPI }

        // MARK: - Services - Linked Banks

        factory { LinkedBankActivationService() as LinkedBankActivationServiceAPI }
    }
}
