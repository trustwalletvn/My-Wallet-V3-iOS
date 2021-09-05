// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ERC20Kit
import FeatureAuthenticationDomain
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

/// The announcement interactor cross all the preliminary data
/// that is required to display announcements to the user
final class AnnouncementInteractor: AnnouncementInteracting {

    // MARK: - Services

    /// Returns announcement preliminary data, according to which the relevant
    /// announcement will be displayed
    var preliminaryData: Single<AnnouncementPreliminaryData> {
        guard wallet.isInitialized() else {
            return Single.error(AnnouncementError.uninitializedWallet)
        }

        let nabuUser = dataRepository.nabuUserSingle
        let tiers = tiersService.tiers
        let sddEligibility = tiersService.checkSimplifiedDueDiligenceEligibility()
            .asObservable()
            .asSingle()
        let countries = infoService.countries
        let simpleBuyOrderDetails = pendingOrderDetailsService.pendingActionOrderDetails

        let isSimpleBuyAvailable = supportedPairsInteractor.pairs
            .map { !$0.pairs.isEmpty }
            .take(1)
            .asSingle()

        let hasAnyWalletBalance = coincore.allAccounts
            .map(\.accounts)
            .flatMap { accounts -> Single<[Bool]> in
                Single.zip(accounts.map { $0.isFunded.catchErrorJustReturn(false) })
            }
            .map { values in
                values.contains(true)
            }

        let hasLinkedBanks = beneficiariesService.hasLinkedBank.take(1).asSingle()
        let isSimpleBuyEligible = simpleBuyEligibilityService.isEligible
        let authenticatorType = repository.authenticatorType
        let announcementAsset: Single<CryptoCurrency?> = featureFetcher
            .fetchString(for: .announcementAsset)
            .optional()
            .catchErrorJustReturn(nil)
            .map { [enabledCurrenciesService] code -> CryptoCurrency? in
                guard let code = code else {
                    return nil
                }
                return CryptoCurrency(
                    code: code,
                    enabledCurrenciesService: enabledCurrenciesService
                )
            }

        return Single.zip(
            nabuUser,
            tiers,
            sddEligibility,
            countries,
            authenticatorType,
            hasAnyWalletBalance,
            Single.zip(
                announcementAsset,
                isSimpleBuyAvailable,
                simpleBuyOrderDetails,
                hasLinkedBanks,
                isSimpleBuyEligible
            )
        )
        .map { payload -> AnnouncementPreliminaryData in
            let (
                user,
                tiers,
                isSDDEligible,
                countries,
                authenticatorType,
                hasAnyWalletBalance,
                (announcementAsset, isSimpleBuyAvailable, pendingOrderDetails, hasLinkedBanks, isSimpleBuyEligible)
            ) = payload
            return AnnouncementPreliminaryData(
                user: user,
                tiers: tiers,
                isSDDEligible: isSDDEligible,
                hasLinkedBanks: hasLinkedBanks,
                countries: countries,
                authenticatorType: authenticatorType,
                pendingOrderDetails: pendingOrderDetails,
                isSimpleBuyAvailable: isSimpleBuyAvailable,
                isSimpleBuyEligible: isSimpleBuyEligible,
                hasAnyWalletBalance: hasAnyWalletBalance,
                announcementAsset: announcementAsset
            )
        }
        .observeOn(MainScheduler.instance)
    }

    // MARK: - Private properties

    private let repository: AuthenticatorRepositoryAPI
    private let wallet: WalletProtocol
    private let dataRepository: BlockchainDataRepository
    private let tiersService: KYCTiersServiceAPI
    private let infoService: GeneralInformationServiceAPI
    private let supportedPairsInteractor: SupportedPairsInteractorServiceAPI
    private let beneficiariesService: BeneficiariesServiceAPI
    private let pendingOrderDetailsService: PendingOrderDetailsServiceAPI
    private let simpleBuyEligibilityService: EligibilityServiceAPI
    private let featureFetcher: FeatureFetching
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let coincore: CoincoreAPI

    // MARK: - Setup

    init(
        repository: AuthenticatorRepositoryAPI = WalletManager.shared.repository,
        wallet: WalletProtocol = WalletManager.shared.wallet,
        dataRepository: BlockchainDataRepository = .shared,
        tiersService: KYCTiersServiceAPI = resolve(),
        featureFetcher: FeatureFetching = resolve(),
        infoService: GeneralInformationServiceAPI = resolve(),
        supportedPairsInteractor: SupportedPairsInteractorServiceAPI = resolve(),
        beneficiariesService: BeneficiariesServiceAPI = resolve(),
        pendingOrderDetailsService: PendingOrderDetailsServiceAPI = resolve(),
        simpleBuyEligibilityService: EligibilityServiceAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        coincore: CoincoreAPI = resolve()
    ) {
        self.repository = repository
        self.wallet = wallet
        self.dataRepository = dataRepository
        self.tiersService = tiersService
        self.infoService = infoService
        self.supportedPairsInteractor = supportedPairsInteractor
        self.beneficiariesService = beneficiariesService
        self.pendingOrderDetailsService = pendingOrderDetailsService
        self.simpleBuyEligibilityService = simpleBuyEligibilityService
        self.coincore = coincore
        self.featureFetcher = featureFetcher
        self.enabledCurrenciesService = enabledCurrenciesService
    }
}
