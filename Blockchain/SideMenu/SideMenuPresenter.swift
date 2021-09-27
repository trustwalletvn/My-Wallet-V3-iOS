// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import DIKit
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Presenter for the side menu of the app. This presenter
/// will handle the logic as to what side menu items should be
/// presented in the SideMenuView.
class SideMenuPresenter {

    // MARK: Public Properties

    var sideMenuItems: AnyPublisher<[SideMenuItem], Never> {
        reactiveWallet
            .waitUntilInitializedSinglePublisher
            .flatMap { [menuItems] _ -> AnyPublisher<[SideMenuItem], Never> in
                menuItems
            }
            .replaceError(with: [])
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    var sideMenuFooterItems: AnyPublisher<(top: SideMenuItem, bottom: SideMenuItem), Never> {
        featureFlagsService
            .isEnabled(.local(.secureChannel))
            .receive(on: DispatchQueue.main)
            .map { [secureChannelConfiguration] isSecureChannelEnabled -> (top: SideMenuItem, bottom: SideMenuItem) in
                (
                    top: (secureChannelConfiguration.isEnabled || isSecureChannelEnabled) ? .secureChannel : .webLogin,
                    bottom: .logout
                )
            }
            .eraseToAnyPublisher()
    }

    var itemSelection: Signal<SideMenuItem> {
        itemSelectionRelay.asSignal()
    }

    // MARK: - Private Properties

    private var menuItems: AnyPublisher<[SideMenuItem], Never> {
        featureFlagsService
            .isEnabled(.local(.interestWithdrawAndDeposit))
            .receive(on: DispatchQueue.main)
            .map { [wallet] interestWithdrawDepositIsEnabled -> [SideMenuItem] in
                var items: [SideMenuItem] = []

                if wallet.isLockboxEnabled() {
                    items.append(.lockbox)
                }

                if interestWithdrawDepositIsEnabled {
                    items.append(.interest)
                }

                items += [
                    .accountsAndAddresses,
                    .buy,
                    .sell,
                    .support,
                    .airdrops,
                    .settings,
                    .exchange
                ]
                return items
            }
            .eraseToAnyPublisher()
    }

    private let featureFlagsService: FeatureFlagsServiceAPI
    private var introductionSequence = WalletIntroductionSequence()
    private let introInterator: WalletIntroductionInteractor
    private let introductionRelay = PublishRelay<WalletIntroductionEventType>()
    private let itemSelectionRelay = PublishRelay<SideMenuItem>()

    // MARK: - Services

    private let wallet: Wallet
    private let walletService: WalletOptionsAPI
    private let reactiveWallet: ReactiveWalletAPI
    private let secureChannelConfiguration: AppFeatureConfiguration
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let disposeBag = DisposeBag()
    private var disposable: Disposable?

    // MARK: - Init

    init(
        wallet: Wallet = WalletManager.shared.wallet,
        walletService: WalletOptionsAPI = resolve(),
        reactiveWallet: ReactiveWalletAPI = WalletManager.shared.reactiveWallet,
        appFeatureConfigurator: AppFeatureConfigurator = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve(),
        onboardingSettings: OnboardingSettings = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.wallet = wallet
        self.walletService = walletService
        self.reactiveWallet = reactiveWallet
        self.featureFlagsService = featureFlagsService
        introInterator = WalletIntroductionInteractor(onboardingSettings: onboardingSettings, screen: .sideMenu)
        self.analyticsRecorder = analyticsRecorder
        secureChannelConfiguration = appFeatureConfigurator.configuration(for: .secureChannel)
    }

    deinit {
        disposable?.dispose()
        disposable = nil
    }

    func loadSideMenu() {
        let startingLocation = introInterator.startingLocation
            .map { [weak self] location -> [WalletIntroductionEvent] in
                self?.startingWithLocation(location) ?? []
            }
            .catchErrorJustReturn([])

        startingLocation
            .subscribe(onSuccess: { [weak self] events in
                guard let self = self else { return }
                self.execute(events: events)
            }, onError: { [weak self] _ in
                guard let self = self else { return }
                self.introductionRelay.accept(.none)
            })
            .disposed(by: disposeBag)
    }

    /// The only reason this is here is for handling the pulse that
    /// is displayed on `buyBitcoin`.
    func onItemSelection(_ item: SideMenuItem) {
        itemSelectionRelay.accept(item)
    }

    private func startingWithLocation(_ location: WalletIntroductionLocation) -> [WalletIntroductionEvent] {
        let screen = location.screen
        guard screen == .sideMenu else { return [] }
        return []
    }

    private func triggerNextStep() {
        guard let next = introductionSequence.next() else {
            introductionRelay.accept(.none)
            return
        }
        /// We track all introduction events that have an analyticsKey.
        /// This happens on presentation.
        if let trackable = next as? WalletIntroductionAnalyticsEvent {
            analyticsRecorder.record(event: trackable.eventType)
        }
        introductionRelay.accept(next.type)
    }

    private func execute(events: [WalletIntroductionEvent]) {
        introductionSequence.reset(to: events)
        triggerNextStep()
    }
}
