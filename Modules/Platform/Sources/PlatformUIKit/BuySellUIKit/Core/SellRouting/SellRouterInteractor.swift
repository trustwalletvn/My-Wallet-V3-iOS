// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RIBs
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// Interactors that controls logics related to data-driven transitions between screens within the Sell flow
public final class SellRouterInteractor: Interactor {

    // MARK: - Types

    /// Comprise all the states so far in the current routing session
    struct States {

        /// The actual state of the flow
        let current: State

        /// The previous states sorted chronologically
        let previous: [State]

        /// All states, ordered
        var all: [State] {
            previous + [current]
        }

        /// A computed inactive state
        static var inactive: States {
            States(current: .inactive, previous: [])
        }

        /// Maps the instance of `States` into a new instance where the appended
        /// state is the current
        func states(byAppending state: State) -> States {
            States(
                current: state,
                previous: previous + [current]
            )
        }

        /// Maps the instance of `States` into a new instance where the last
        /// state is trimmed off. In case `previous` is an empty array, `current` will be
        /// `.inactive`.
        func statesByRemovingLast() -> States {
            States(
                current: previous.last ?? .inactive,
                previous: previous.dropLast()
            )
        }
    }

    /// Marks a past or present state in the state-machine
    enum State {

        /// Inactive state - pre flow
        case inactive

        /// The user is ineligible for `Sell`
        case ineligible

        /// The user has been KYC rejected
        case verificationFailed

        /// The SFScreenViewController showing the region availability URL
        /// for an ineligible user
        case ineligibilityURL

        /// The SFScreenViewController showing the form to contact support
        case contactSupportURL

        /// An introduction screen that should show if the user
        /// has not completed KYC
        case introduction

        /// The user has not completed KYC
        case kyc

        /// Account Selection Screen
        case accountSelector

        /// Fiat Account Selection Screen
        case fiatAccountSelector

        /// Enter amount
        case enterAmount(SellCryptoInteractionData)

        /// The user is checking-out
        case checkout(CheckoutData)

        /// Sell completed
        case pendingOrderCompleted(orderDetails: OrderDetails)

        /// Completed state
        case completed

        /// Cancelled Transaction State
        case cancel(CheckoutData)
    }

    enum Action {
        case next(to: State)
        case previous(from: State)
        case dismiss
    }

    // MARK: - Properties

    var action: Signal<Action> {
        actionRelay.asSignal()
    }

    public let previousRelay = PublishRelay<Void>()
    private let sourceSelectionRelay = BehaviorRelay<CryptoTradingAccount?>(value: nil)

    private lazy var setup: Void = {
        let selection = accountSelectionService
            .selectedData
            .share(replay: 1)

        selection
            // Any `CryptoTradingAccount` selected should be set as 'source'.
            .compactMap { $0 as? CryptoTradingAccount }
            .bindAndCatch(weak: self) { (self, account) in
                self.sourceSelectionRelay.accept(account)
                let states = States(current: .fiatAccountSelector, previous: [.accountSelector])
                self.apply(action: .next(to: states.current), states: states)
            }
            .disposed(by: disposeBag)

        selection
            // Any `FiatAccount` selected should be set as 'target'.
            .compactMap { $0 as? FiatAccount }
            .withLatestFrom(sourceSelectionRelay) { (fiatAccount: $0, cryptoAccount: $1) }
            .compactMap { accounts -> SellCryptoInteractionData? in
                guard let cryptoAccount = accounts.cryptoAccount else { return nil }
                return SellCryptoInteractionData(
                    source: cryptoAccount,
                    destination: accounts.fiatAccount
                )
            }
            .map { States(current: .enterAmount($0), previous: [.inactive]) }
            .bindAndCatch(weak: self) { (self, states) in
                self.apply(action: .next(to: states.current), states: states)
            }
            .disposed(by: disposeBag)
    }()

    private let eligibilityService: EligibilityServiceAPI
    private let kycTiersService: KYCTiersServiceAPI
    private let accountSelectionService: AccountSelectionServiceAPI
    private let loader: LoadingViewPresenting
    private let alert: AlertViewPresenterAPI

    private let statesRelay = BehaviorRelay<States>(value: .inactive)
    private let actionRelay = PublishRelay<Action>()
    private var disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        accountSelectionService: AccountSelectionServiceAPI,
        eligibilityService: EligibilityServiceAPI = resolve(),
        kycTiersService: KYCTiersServiceAPI = resolve(),
        loader: LoadingViewPresenting = resolve(),
        alert: AlertViewPresenterAPI = resolve()
    ) {
        self.eligibilityService = eligibilityService
        self.kycTiersService = kycTiersService
        self.accountSelectionService = accountSelectionService
        self.loader = loader
        self.alert = alert
        super.init()
        _ = setup
    }

    // MARK: - Lifecycle

    override public func didBecomeActive() {
        super.didBecomeActive()

        previousRelay
            .observeOn(MainScheduler.instance)
            .bindAndCatch(weak: self) { (self) in self.previous() }
            .disposed(by: disposeBag)

        let eligibility: Single<Bool> = eligibilityService.fetch()

        Single.zip(
            kycTiersService.fetchTiers(),
            eligibility
        )
        .map { (tiers: $0.0, eligible: $0.1) }
        .handleLoaderForLifecycle(
            loader: loader,
            style: .circle
        )
        .map { (tiers: KYC.UserTiers, eligible: Bool) -> State in
            let status = tiers.tierAccountStatus(for: .tier2)
            switch (status, eligible) {
            case (.none, _):
                /// The user has not completed KYC
                return .introduction
            case (.approved, true):
                /// The user is KYC approved and is eligible
                return .accountSelector
            case (.approved, false):
                /// The user is KYC approved and is ineligible
                return .ineligible
            case (.failed, _),
                 (.expired, _):
                /// The user have been rejected
                return .verificationFailed
            case (.underReview, _),
                 (.pending, _):
                /// If the user's KYC status is still under-review
                /// or pending, we can just start KYC and it will show their status.
                return .kyc
            }
        }
        .map { States(current: $0, previous: [.inactive]) }
        .subscribe(onSuccess: { [weak self] states in
            guard let self = self else { return }
            self.apply(action: .next(to: states.current), states: states)
        })
        .disposed(by: disposeBag)
    }

    override public func willResignActive() {
        super.willResignActive()
        disposeBag = DisposeBag()
    }

    public func nextFromVerificationFailed() {
        let states = States(current: .contactSupportURL, previous: [.inactive])
        apply(action: .next(to: states.current), states: states)
    }

    public func nextFromIneligible() {
        let states = States(current: .ineligibilityURL, previous: [.inactive])
        apply(action: .next(to: states.current), states: states)
    }

    public func nextFromIntroduction() {
        let states = States(current: .kyc, previous: [.inactive])
        apply(action: .next(to: states.current), states: states)
    }

    public func nextFromKYC() {
        kycTiersService.fetchTiers()
            .handleLoaderForLifecycle(
                loader: loader,
                style: .circle
            )
            .map { tiers -> States in
                let state: State = tiers.isTier2Approved ? .accountSelector : .inactive
                let states = States(current: state, previous: [.inactive])
                return states
            }
            .subscribe(onSuccess: { [weak self] states in
                guard let self = self else { return }
                self.apply(action: .next(to: states.current), states: states)
            })
            .disposed(by: disposeBag)
    }

    public func nextFromSellCrypto(checkoutData: CheckoutData) {
        let state: State = .checkout(checkoutData)
        let current = statesRelay.value
        let states = States(current: state, previous: [current.current])
        apply(action: .next(to: states.current), states: states)
    }

    public func cancelSell(with checkoutData: CheckoutData) {
        let states = self.states(byAppending: .cancel(checkoutData))
        apply(action: .next(to: states.current), states: states)
    }

    public func orderCompleted() {
        let states = self.states(byAppending: .completed)
        apply(action: .dismiss, states: states)
    }

    public func orderPending(with orderDetails: OrderDetails) {
        let checkoutData = CheckoutData(order: orderDetails)
        let state = State.checkout(checkoutData)
        apply(
            action: .next(to: state),
            states: states(byAppending: state)
        )
    }

    public func confirmCheckout(with checkoutData: CheckoutData, isOrderNew: Bool) {
        let state: State
        let data = (checkoutData.order.paymentMethod, isOrderNew)
        switch data {
        case (.funds, true):
            state = .pendingOrderCompleted(
                orderDetails: checkoutData.order
            )
        case (.funds, false):
            state = .inactive
        default:
            fatalError("This should not happen.")
        }

        let states = self.states(byAppending: state)
        apply(action: .next(to: state), states: states)
    }

    // MARK: - Accessors

    private func previous() {
        let last = statesRelay.value.current
        let states = statesRelay.value.statesByRemovingLast()
        let current = states.current
        let action: Action
        switch (last, current) {
        /// Dismiss in case the current state is `inactive`.
        case (_, .inactive):
            action = .dismiss
        default:
            action = .previous(from: last)
        }
        apply(action: action, states: states)
    }

    private func apply(action: Action, states: States) {
        actionRelay.accept(action)
        statesRelay.accept(states)
    }

    private func statesByRemovingLast() -> States {
        statesRelay.value.statesByRemovingLast()
    }

    private func states(byAppending state: State) -> States {
        statesRelay.value.states(byAppending: state)
    }
}
