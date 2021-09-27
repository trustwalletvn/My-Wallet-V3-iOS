// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import FeatureAuthenticationDomain
import PlatformKit
import RxSwift
import ToolKit

/// This class connect the analytics service with the application layer
final class AnalyticsUserPropertyInteractor {

    // MARK: - Properties

    private let coincore: CoincoreAPI
    private let dataRepository: BlockchainDataRepository
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let recorder: UserPropertyRecording
    private let tiersService: KYCTiersServiceAPI
    private let walletRepository: WalletRepositoryAPI
    private var disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        coincore: CoincoreAPI = resolve(),
        dataRepository: BlockchainDataRepository = .shared,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        recorder: UserPropertyRecording = AnalyticsUserPropertyRecorder(),
        tiersService: KYCTiersServiceAPI = resolve(),
        walletRepository: WalletRepositoryAPI = resolve()
    ) {
        self.coincore = coincore
        self.dataRepository = dataRepository
        self.fiatCurrencyService = fiatCurrencyService
        self.recorder = recorder
        self.tiersService = tiersService
        self.walletRepository = walletRepository
    }

    func fiatBalances() -> Single<[CryptoCurrency: MoneyValue]> {
        let balances: [Single<(asset: CryptoCurrency, moneyValue: MoneyValue?)>] = coincore.cryptoAssets
            .map { asset in
                asset.accountGroup(filter: .all)
                    .asObservable()
                    .asSingle()
                    .flatMap { accountGroup -> Single<MoneyValue> in
                        // We want to record the fiat balance analytics event always in USD.
                        accountGroup.fiatBalance(fiatCurrency: .USD)
                    }
                    .optional()
                    .catchErrorJustReturn(nil)
                    .map { (asset: asset.asset, moneyValue: $0) }
            }
        return Single.zip(balances)
            .map { items in
                items.reduce(into: [CryptoCurrency: MoneyValue]()) { result, item in
                    result[item.asset] = item.moneyValue
                }
            }
    }

    /// Records all the user properties
    func record() {
        disposeBag = DisposeBag()
        Single
            .zip(
                dataRepository.nabuUserSingle,
                tiersService.tiers,
                walletRepository.authenticatorType,
                walletRepository.guid,
                fiatBalances()
            )
            .subscribe(
                onSuccess: { [weak self] user, tiers, authenticatorType, guid, balances in
                    self?.record(
                        user: user,
                        tiers: tiers,
                        authenticatorType: authenticatorType,
                        guid: guid,
                        balances: balances
                    )
                },
                onError: { error in
                    Logger.shared.error(error)
                }
            )
            .disposed(by: disposeBag)
    }

    private func record(
        user: NabuUser?,
        tiers: KYC.UserTiers?,
        authenticatorType: WalletAuthenticatorType,
        guid: String?,
        balances: [CryptoCurrency: MoneyValue]
    ) {
        if let identifier = user?.personalDetails.identifier {
            recorder.record(id: identifier)
        }

        if let guid = guid {
            let property = HashedUserProperty(key: .walletID, value: guid)
            recorder.record(property)
        }

        if let tiers = tiers {
            let value = "\(tiers.latestTier.rawValue)"
            recorder.record(StandardUserProperty(key: .kycLevel, value: value))
        }

        if let date = user?.kycCreationDate {
            recorder.record(StandardUserProperty(key: .kycCreationDate, value: date))
        }

        if let date = user?.kycUpdateDate {
            recorder.record(StandardUserProperty(key: .kycUpdateDate, value: date))
        }

        if let isEmailVerified = user?.email.verified {
            recorder.record(StandardUserProperty(key: .emailVerified, value: String(isEmailVerified)))
        }

        recorder.record(StandardUserProperty(key: .twoFAEnabled, value: String(authenticatorType.isTwoFactor)))

        let positives: [String] = balances
            .filter(\.value.isPositive)
            .map(\.key.code)

        let totalFiatBalance = try? balances.values.reduce(FiatValue.zero(currency: .USD).moneyValue, +)

        recorder.record(
            StandardUserProperty(key: .fundedCoins, value: positives.joined(separator: ","))
        )
        recorder.record(
            StandardUserProperty(key: .totalBalance, value: balanceBucket(for: totalFiatBalance?.amount ?? 0))
        )
    }

    /// Total balance (measured in USD) in buckets: 0, 0-10, 10-100, 100-1000, >1000
    private func balanceBucket(for minorUSDBalance: BigInt) -> String {
        switch minorUSDBalance {
        case ...099:
            return "0 USD"
        case 100...1099:
            return "1-10 USD"
        case 1100...10099:
            return "11-100 USD"
        case 10100...100099:
            return "101-1000 USD"
        case 100100...:
            return "1001 USD"
        default:
            return "0 USD"
        }
    }
}
