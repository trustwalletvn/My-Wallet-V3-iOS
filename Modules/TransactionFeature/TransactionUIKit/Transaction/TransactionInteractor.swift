// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit
import TransactionKit

final class TransactionInteractor {

    private enum Error: LocalizedError {
        case loadingFailed(account: BlockchainAccount, action: AssetAction, error: String)

        var errorDescription: String? {
            switch self {
            case .loadingFailed(let account, let action, let error):
                let type = String(reflecting: account)
                let asset = account.currencyType.code
                let label = account.label
                return "Failed to load: '\(type)' asset '\(asset)' label '\(label)' action '\(action)' error '\(error)'."
            }
        }
    }

    private let coincore: CoincoreAPI
    private let availablePairsService: AvailableTradingPairsServiceAPI
    private let swapEligibilityService: EligibilityServiceAPI
    private let paymentMethodsService: PaymentAccountsServiceAPI
    private let linkedBanksFactory: LinkedBanksFactoryAPI
    private let errorRecorder: ErrorRecording
    private var transactionProcessor: TransactionProcessor?

    /// Used to invalidate the transaction processor chain.
    private let invalidate = PublishSubject<Void>()

    init(
        coincore: CoincoreAPI = resolve(),
        availablePairsService: AvailableTradingPairsServiceAPI = resolve(),
        swapEligibilityService: EligibilityServiceAPI = resolve(),
        paymentMethodsService: PaymentAccountsServiceAPI = resolve(),
        linkedBanksFactory: LinkedBanksFactoryAPI = resolve(),
        errorRecorder: ErrorRecording = resolve()
    ) {
        self.coincore = coincore
        self.errorRecorder = errorRecorder
        self.availablePairsService = availablePairsService
        self.swapEligibilityService = swapEligibilityService
        self.paymentMethodsService = paymentMethodsService
        self.linkedBanksFactory = linkedBanksFactory
    }

    func initializeTransaction(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        action: AssetAction
    ) -> Observable<PendingTransaction> {
        coincore
            .createTransactionProcessor(
                with: sourceAccount,
                target: transactionTarget,
                action: action
            )
            .do(onSuccess: { [weak self] transactionProcessor in
                guard let self = self else { return }
                self.transactionProcessor = transactionProcessor
            })
            .asObservable()
            .flatMap(\.initializeTransaction)
            .takeUntil(invalidate)
    }

    deinit {
        reset()
        self.transactionProcessor = nil
    }

    func invalidateTransaction() -> Completable {
        Completable.create(weak: self) { (self, complete) -> Disposable in
            self.reset()
            self.transactionProcessor = nil
            complete(.completed)
            return Disposables.create()
        }
    }

    func update(amount: MoneyValue) -> Completable {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.updateAmount(amount: amount)
    }

    func updateTransactionFees(with level: FeeLevel, amount: MoneyValue?) -> Completable {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.updateFeeLevel(level, customFeeAmount: amount)
    }

    func fetchPaymentAccounts(for currency: CryptoCurrency, amount: MoneyValue?) -> Single<[SingleAccount]> {
        let amount = amount ?? .zero(currency: currency)
        return paymentMethodsService
            .fetchPaymentAccounts(for: currency, amount: amount)
            .map { $0 }
            .asSingle()
    }

    func getAvailableSourceAccounts(action: AssetAction) -> Single<[SingleAccount]> {
        switch action {
        case .buy:
            // TODO: check the new limits API to understand whether passing asset and amount is really required
            return fetchPaymentAccounts(for: .coin(.bitcoin), amount: nil)
        case .swap:
            let tradingPairs = availablePairsService.availableTradingPairs
            let allAccounts = coincore.allAccounts
                .map(\.accounts)
                .flatMapFilter(
                    action: action,
                    failSequence: false,
                    onError: { [errorRecorder] account, error in
                        let error: Error = .loadingFailed(
                            account: account,
                            action: action,
                            error: String(describing: error)
                        )
                        errorRecorder.error(error)
                    }
                )
                .map { accounts in
                    accounts.compactMap { account in
                        account as? CryptoAccount
                    }
                }
            return Single.zip(allAccounts, tradingPairs)
                .map { (allAccounts: [CryptoAccount], tradingPairs: [OrderPair]) -> [CryptoAccount] in
                    allAccounts.filter { account -> Bool in
                        account.isAvailableToSwapFrom(tradingPairs: tradingPairs)
                    }
                }
        case .deposit:
            return linkedBanksFactory.linkedBanks.map { $0.map { $0 as SingleAccount } }
        default:
            preconditionFailure("Source account should be preselected for action \(action)")
        }
    }

    func getTargetAccounts(sourceAccount: BlockchainAccount, action: AssetAction) -> Single<[SingleAccount]> {
        switch action {
        case .swap:
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected a CryptoAccount.")
            }
            return swapTargets(sourceAccount: cryptoAccount)
        case .send:
            guard let cryptoAccount = sourceAccount as? CryptoAccount else {
                fatalError("Expected a CryptoAccount.")
            }
            return sendTargets(sourceAccount: cryptoAccount)
        case .deposit:
            return linkedBanksFactory.nonWireTransferBanks.map { $0.map { $0 as SingleAccount } }
        case .withdraw:
            return linkedBanksFactory.linkedBanks.map { $0.map { $0 as SingleAccount } }
        case .buy:
            return coincore
                .cryptoAccounts(supporting: .buy)
                .asSingle()
                .map { $0 }
        case .receive,
             .sell,
             .viewActivity:
            unimplemented()
        }
    }

    func verifyAndExecute(secondPassword: String) -> Single<TransactionResult> {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.execute(secondPassword: secondPassword)
    }

    func modifyTransactionConfirmation(_ newConfirmation: TransactionConfirmation) -> Completable {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.set(transactionConfirmation: newConfirmation)
    }

    func reset() {
        invalidate.on(.next(()))
        transactionProcessor?.reset()
    }

    var startCryptoRatePairFetch: Observable<MoneyValuePair> {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.transactionExchangeRatePair
    }

    var startFiatRatePairsFetch: Observable<TransactionMoneyValuePairs> {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.fiatExchangeRatePairs
    }

    var canTransactFiat: Bool {
        transactionProcessor?.canTransactFiat ?? false
    }

    var validateTransaction: Completable {
        guard let transactionProcessor = transactionProcessor else {
            fatalError("Tx Processor is nil")
        }
        return transactionProcessor.validateAll()
    }

    // MARK: - Private Functions

    private func sendTargets(sourceAccount: CryptoAccount) -> Single<[SingleAccount]> {
        coincore
            .getTransactionTargets(
                sourceAccount: sourceAccount,
                action: .send
            )
    }

    private func swapTargets(sourceAccount: CryptoAccount) -> Single<[SingleAccount]> {
        let transactionTargets = coincore
            .getTransactionTargets(
                sourceAccount: sourceAccount,
                action: .swap
            )
        let tradingPairs = availablePairsService.availableTradingPairs
        let isEligible = swapEligibilityService.isEligible
        return Single.zip(transactionTargets, tradingPairs, isEligible)
            .map { (accounts: [SingleAccount], pairs: [OrderPair], isEligible: Bool) -> [SingleAccount] in
                accounts
                    .filter { $0 is CryptoAccount }
                    .filter { pairs.contains(source: sourceAccount.currencyType, destination: $0.currencyType) }
                    .filter { isEligible || $0 is NonCustodialAccount }
            }
    }
}

extension Array where Element == OrderPair {
    fileprivate func contains(source: CurrencyType, destination: CurrencyType) -> Bool {
        contains(where: { $0.sourceCurrencyType == source && $0.destinationCurrencyType == destination })
    }
}

extension CryptoAccount {
    fileprivate func isAvailableToSwapFrom(tradingPairs: [OrderPair]) -> Bool {
        tradingPairs.contains { pair in
            pair.sourceCurrencyType == asset
        }
    }
}
