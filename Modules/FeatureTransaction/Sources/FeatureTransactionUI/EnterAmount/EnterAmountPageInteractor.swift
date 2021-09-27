// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa
import RxSwift
import ToolKit

protocol EnterAmountPageRouting: AnyObject {
    func showFeeSelectionSheet(with transactionModel: TransactionModel)
    func showError(_ error: Error)
}

protocol EnterAmountPageListener: AnyObject {
    func enterAmountDidTapBack()
    func closeFlow()
    func continueToKYCTiersScreen()
    func showGenericFailure(error: Error)
}

protocol EnterAmountPagePresentable: Presentable {

    var continueButtonTapped: Signal<Void> { get }

    func connect(
        state: Driver<EnterAmountPageInteractor.State>
    ) -> Driver<EnterAmountPageInteractor.NavigationEffects>
}

protocol AuxiliaryViewPresenting: AnyObject {

    func makeViewController() -> UIViewController
}

final class EnterAmountPageInteractor: PresentableInteractor<EnterAmountPagePresentable>, EnterAmountPageInteractable {

    weak var router: EnterAmountPageRouting?
    weak var listener: EnterAmountPageListener?

    private var topAuxiliaryViewPresenter: AuxiliaryViewPresenting?

    /// The interactor that `SendAuxiliaryViewPresenter` uses
    private let sendAuxiliaryViewInteractor: SendAuxiliaryViewInteractor
    private let sendAuxiliaryViewPresenter: SendAuxiliaryViewPresenter

    private let accountAuxiliaryViewInteractor: AccountAuxiliaryViewInteractor
    private let accountAuxiliaryViewPresenter: AccountAuxiliaryViewPresenter

    /// The interactor that `SingleAmountPreseneter` uses
    private let amountViewInteractor: AmountViewInteracting

    private let transactionModel: TransactionModel
    private let analyticsHook: TransactionAnalyticsHook
    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel

    init(
        transactionModel: TransactionModel,
        presenter: EnterAmountPagePresentable,
        amountInteractor: AmountViewInteracting,
        action: AssetAction,
        navigationModel: ScreenNavigationModel,
        analyticsHook: TransactionAnalyticsHook = resolve()
    ) {
        self.action = action
        self.transactionModel = transactionModel
        amountViewInteractor = amountInteractor
        self.navigationModel = navigationModel
        self.analyticsHook = analyticsHook
        sendAuxiliaryViewInteractor = SendAuxiliaryViewInteractor()
        sendAuxiliaryViewPresenter = SendAuxiliaryViewPresenter(
            interactor: sendAuxiliaryViewInteractor
        )
        accountAuxiliaryViewInteractor = AccountAuxiliaryViewInteractor()
        accountAuxiliaryViewPresenter = AccountAuxiliaryViewPresenter(
            interactor: accountAuxiliaryViewInteractor
        )
        super.init(presenter: presenter)
    }

    // TODO: Clean up this function
    // swiftlint:disable function_body_length
    override func didBecomeActive() {
        super.didBecomeActive()

        let transactionState: Observable<TransactionState> = transactionModel
            .state
            .share(replay: 1, scope: .whileConnected)

        // THIS IS NO AMOUNT CONVERSION. NAME IS CONFUSING.
        amountViewInteractor
            .effect
            .subscribe { [weak self] effect in
                self?.handleAmountTranslation(effect: effect)
            }
            .disposeOnDeactivate(interactor: self)

        amountViewInteractor
            .amount
            .debounce(.milliseconds(250), scheduler: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
            .flatMap { amount -> Observable<MoneyValue> in
                transactionState
                    .take(1)
                    .asSingle()
                    .map { state in
                        if let fiatValue = amount.fiatValue, !state.allowFiatInput {
                            // Fiat Input but state does not allow fiat
                            guard let sourceToFiatPair = state.sourceToFiatPair else {
                                return MoneyValue.zero(currency: state.asset)
                            }
                            return MoneyValuePair(
                                fiatValue: fiatValue,
                                exchangeRate: sourceToFiatPair.quote.fiatValue!,
                                cryptoCurrency: state.asset.cryptoCurrency!,
                                usesFiatAsBase: true
                            ).quote
                        }
                        return amount
                    }
                    .asObservable()
            }
            .subscribe { [weak self] (amount: MoneyValue) in
                self?.transactionModel.process(action: .updateAmount(amount))
            }
            .disposeOnDeactivate(interactor: self)

        let spendable = Observable
            .combineLatest(
                transactionState,
                amountViewInteractor.activeInput
            )
            .map { state, input in
                (
                    min: state.minSpendable.displayableRounding(roundingMode: .up),
                    max: state.maxSpendable.displayableRounding(roundingMode: .down),
                    errorState: state.errorState,
                    exchangeRate: state.sourceToFiatPair,
                    activeInput: input,
                    amount: state.amount
                )
            }
            .share(scope: .whileConnected)

        transactionState
            .distinctUntilChanged(\.feeSelection, comparer: { $0 == $1 })
            .filter { $0.feeSelection.selectedLevel != .none }
            .subscribe(onNext: { [analyticsHook] state in
                analyticsHook.onFeeSelected(state: state)
            })
            .disposeOnDeactivate(interactor: self)

        let availableSources = transactionState
            .map(\.availableSources)
            .share(scope: .whileConnected)

        let availableTargets = transactionState
            .map(\.availableTargets)
            .map { $0.compactMap { $0 as? BlockchainAccount } }
            .share(scope: .whileConnected)

        let fee = transactionState
            .takeWhile { $0.action == .send }
            .compactMap(\.pendingTransaction)
            .map(\.feeAmount)
            .share(scope: .whileConnected)

        let auxiliaryViewAccount = transactionState
            .takeWhile { $0.action.supportsBottomAccountsView }
            .map { state -> BlockchainAccount? in
                switch state.action {
                case .buy,
                     .deposit:
                    return state.source
                case .sell,
                     .withdraw:
                    return state.destination as? BlockchainAccount
                case .viewActivity,
                     .send,
                     .receive,
                     .swap:
                    fatalError("Unsupported action")
                }
            }
            .compactMap { $0 }
            .share(scope: .whileConnected)

        let bottomAuxiliaryViewAccounts = Observable.combineLatest(
            availableSources,
            availableTargets
        )
        .map { [action] availableSources, availableTargets -> [Account] in
            guard action == .buy || action == .deposit else {
                return availableTargets
            }
            return availableSources
        }

        accountAuxiliaryViewInteractor
            .connect(
                stream: auxiliaryViewAccount,
                availableAccounts: bottomAuxiliaryViewAccounts
            )
            .disposeOnDeactivate(interactor: self)

        accountAuxiliaryViewInteractor
            .auxiliaryViewTapped
            .withLatestFrom(transactionState)
            .subscribe(onNext: { [weak self] state in
                self?.handleBottomAuxiliaryViewTapped(state: state)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .connect(fee: fee)
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .connect(stream: spendable.map(\.max))
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .resetToMaxAmount
            .withLatestFrom(spendable.map(\.max))
            .subscribe(onNext: { [weak self] maxSpendable in
                self?.amountViewInteractor.set(amount: maxSpendable)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .resetToMaxAmount
            .withLatestFrom(transactionState)
            .subscribe(onNext: { [analyticsHook] state in
                analyticsHook.onMaxSelected(state: state)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .availableBalanceTapped
            .withLatestFrom(spendable.map(\.max))
            .subscribe(onNext: { [weak self] maxSpendable in
                self?.amountViewInteractor.set(amount: maxSpendable)
            })
            .disposeOnDeactivate(interactor: self)

        sendAuxiliaryViewInteractor
            .networkFeeTapped
            .bindAndCatch(weak: self) { (self, _) in
                self.router?.showFeeSelectionSheet(with: self.transactionModel)
            }
            .disposeOnDeactivate(interactor: self)

        spendable
            .map { [weak listener] spendable in
                spendable.errorState.toAmountInteractorState(
                    min: spendable.min,
                    max: spendable.max,
                    exchangeRate: spendable.exchangeRate,
                    activeInput: spendable.activeInput,
                    stateAmount: spendable.amount,
                    listener: listener
                )
            }
            .bindAndCatch(to: amountViewInteractor.stateRelay)
            .disposeOnDeactivate(interactor: self)

        let interactorState = transactionState
            .scan(initialState()) { [weak self] currentState, updater -> State in
                guard let self = self else {
                    return currentState
                }
                return self.calculateNextState(
                    with: currentState,
                    updater: updater
                )
            }
            .asDriverCatchError()

        presenter
            .continueButtonTapped
            .asObservable()
            .withLatestFrom(transactionState)
            .subscribe(onNext: { [transactionModel, analyticsHook] state in
                switch state.action {
                case .buy:
                    transactionModel.process(action: .performKYCChecks)
                default:
                    transactionModel.process(action: .prepareTransaction)
                }
                analyticsHook.onEnterAmountContinue(with: state)
            })
            .disposeOnDeactivate(interactor: self)

        presenter
            .connect(state: interactorState)
            .drive(onNext: handle(effects:))
            .disposeOnDeactivate(interactor: self)

        transactionState
            .compactMap { state -> (
                action: AssetAction,
                amountIsZero: Bool,
                networkFeeAdjustmentSupported: Bool
            )? in
            guard let pendingTransaction = state.pendingTransaction else {
                return nil
            }
            return (
                state.action,
                state.amount.isZero,
                pendingTransaction.availableFeeLevels.networkFeeAdjustmentSupported
            )
            }
            .map { action, amountIsZero, networkFeeAdjustmentSupported in
                (action, (networkFeeAdjustmentSupported && action == .send && !amountIsZero) ? .visible : .hidden)
            }
            .map { action, networkFeeVisibility -> SendAuxiliaryViewPresenter.State in
                SendAuxiliaryViewPresenter.State(
                    maxButtonVisibility: networkFeeVisibility.inverted,
                    networkFeeVisibility: networkFeeVisibility,
                    bitpayVisibility: .hidden,
                    availableBalanceTitle: TransactionFlowDescriptor.availableBalanceTitle,
                    maxButtonTitle: TransactionFlowDescriptor.maxButtonTitle(action: action)
                )
            }
            .bindAndCatch(to: sendAuxiliaryViewPresenter.stateRelay)
            .disposeOnDeactivate(interactor: self)
    }

    func handleTopAuxiliaryViewTapped(state: TransactionState) {
        switch state.action {
        case .buy:
            transactionModel.process(action: .showTargetSelection)
        default:
            break
        }
    }

    private func handleBottomAuxiliaryViewTapped(state: TransactionState) {
        switch state.action {
        case .buy,
             .deposit:
            transactionModel.process(action: .showSourceSelection)
        case .sell,
             .withdraw:
            transactionModel.process(action: .showTargetSelection)
        default:
            unimplemented("This view only supports withdraw and deposit at this time")
        }
    }

    // MARK: - Private methods

    private func calculateNextState(
        with state: State,
        updater: TransactionState
    ) -> State {
        state
            .update(\.canContinue, value: updater.nextEnabled)
            .update(\.topAuxiliaryViewPresenter, value: topAuxiliaryView(for: updater))
            .update(\.bottomAuxiliaryViewPresenter, value: bottomAuxiliaryView(for: updater))
    }

    private func topAuxiliaryView(for transactionState: TransactionState) -> AuxiliaryViewPresenting? {
        let presenter: AuxiliaryViewPresenting?
        if transactionState.action.supportsTopAccountsView {
            let interactor = TargetAuxiliaryViewInteractor(enterAmountInteractor: self)
            presenter = TargetAuxiliaryViewPresenter(interactor: interactor, transactionState: transactionState)
        } else {
            presenter = InfoAuxiliaryViewPresenter(transactionState: transactionState)
        }
        topAuxiliaryViewPresenter = presenter
        return presenter
    }

    private func bottomAuxiliaryView(for transactionState: TransactionState) -> AuxiliaryViewPresenting? {
        action.supportsBottomAccountsView ? accountAuxiliaryViewPresenter : sendAuxiliaryViewPresenter
    }

    private func handle(effects: NavigationEffects) {
        switch effects {
        case .back:
            listener?.enterAmountDidTapBack()
        case .close:
            listener?.closeFlow()
        case .none:
            break
        }
    }

    private func handleAmountTranslation(effect: AmountInteractorEffect) {
        switch effect {
        case .failure(let error):
            listener?.showGenericFailure(error: error)
        case .none:
            break
        }
    }
}

extension EnterAmountPageInteractor {

    struct State: Equatable {
        var topAuxiliaryViewPresenter: AuxiliaryViewPresenting?
        var bottomAuxiliaryViewPresenter: AuxiliaryViewPresenting?
        var navigationModel: ScreenNavigationModel
        var canContinue: Bool

        static func == (lhs: EnterAmountPageInteractor.State, rhs: EnterAmountPageInteractor.State) -> Bool {
            lhs.topAuxiliaryViewPresenter === rhs.topAuxiliaryViewPresenter
                && lhs.bottomAuxiliaryViewPresenter === rhs.bottomAuxiliaryViewPresenter
                && lhs.navigationModel == rhs.navigationModel
                && lhs.canContinue == rhs.canContinue
        }
    }

    private func initialState() -> State {
        State(
            topAuxiliaryViewPresenter: nil,
            bottomAuxiliaryViewPresenter: nil,
            navigationModel: navigationModel,
            canContinue: false
        )
    }
}

extension EnterAmountPageInteractor {

    enum NavigationEffects {
        case back
        case close
        case none
    }
}

extension EnterAmountPageInteractor.State {

    func update<Value>(_ keyPath: WritableKeyPath<Self, Value>, value: Value) -> Self {
        var updated = self
        updated[keyPath: keyPath] = value
        return updated
    }
}

extension TransactionErrorState {

    private typealias LocalizedString = LocalizationConstants.Transaction

    func toAmountInteractorState(
        min: MoneyValue,
        max: MoneyValue,
        exchangeRate: MoneyValuePair?,
        activeInput: ActiveAmountInput,
        stateAmount: MoneyValue,
        listener: EnterAmountPageListener?
    ) -> AmountInteractorState {
        switch self {
        case .none:
            return .inBounds

        case .insufficientGas:
            return .error(
                message: LocalizedString.Confirmation.Error.insufficientGas
            )

        case .overSilverTierLimit:
            return .warning(
                message: LocalizedString.Swap.KYC.overSilverLimitWarning,
                action: { [weak listener] in
                    listener?.continueToKYCTiersScreen()
                }
            )

        case .overGoldTierLimit,
             .overMaximumLimit,
             .insufficientFundsForFees,
             .insufficientFunds:
            let result = convertToInputCurrency(max, exchangeRate: exchangeRate, input: activeInput)
            return .maxLimitExceeded(result)

        case .belowMinimumLimit:
            guard !stateAmount.isZero else {
                return .inBounds
            }
            let result = convertToInputCurrency(min, exchangeRate: exchangeRate, input: activeInput)
            return .underMinLimit(result)

        case .addressIsContract,
             .invalidAddress,
             .invalidAmount,
             .invalidPassword,
             .optionInvalid,
             .transactionInFlight,
             .pendingOrdersLimitReached,
             .unknownError,
             .nabuError,
             .fatalError:
            return .empty
        }
    }

    private func convertToInputCurrency(
        _ source: MoneyValue,
        exchangeRate: MoneyValuePair?,
        input: ActiveAmountInput
    ) -> MoneyValue {
        switch (source.currencyType, input) {
        case (.crypto, .crypto),
             (.fiat, .fiat):
            return source
        case (.crypto, .fiat):
            // Convert crypto max amount into fiat amount.
            guard let exchangeRate = exchangeRate else {
                // No exchange rate yet, use original value for error message.
                return source
            }
            // Convert crypto max amount into fiat amount.
            guard let result = try? source.convert(using: exchangeRate.quote) else {
                // Can't convert, use original value for error message.
                return source
            }
            return result
        case (.fiat, .crypto):
            guard let quote = exchangeRate?.quote,
                  let result = try? source.convert(usingInverse: quote, currencyType: source.currencyType)
            else {
                // Can't convert, use original value for error message.
                return source
            }
            return result
        }
    }
}

extension AssetAction {

    fileprivate var supportsTopAccountsView: Bool {
        switch self {
        case .buy:
            return true
        default:
            return false
        }
    }

    fileprivate var supportsBottomAccountsView: Bool {
        switch self {
        case .buy,
             .sell,
             .deposit,
             .withdraw:
            return true
        default:
            return false
        }
    }
}
