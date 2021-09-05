// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

public final class InterestDepositTradingTransationEngine: InterestTransactionEngine {

    // MARK: - InterestTransactionEngine

    public var minimumDepositLimits: Single<FiatValue> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap { [sourceCryptoCurrency, accountLimitsRepository] fiatCurrency in
                accountLimitsRepository
                    .fetchInterestAccountLimitsForCryptoCurrency(
                        sourceCryptoCurrency,
                        fiatCurrency: fiatCurrency
                    )
                    .asObservable()
                    .take(1)
                    .asSingle()
            }
            .map(\.minDepositAmount)
    }

    // MARK: - TransactionEngine

    public var askForRefreshConfirmation: (AskForRefreshConfirmation)!
    public var sourceAccount: BlockchainAccount!
    public var transactionTarget: TransactionTarget!

    public var requireSecondPassword: Bool

    // MARK: - InterestTransactionEngine

    public let priceService: PriceServiceAPI
    public let fiatCurrencyService: FiatCurrencyServiceAPI

    // MARK: - Private Properties

    private var minimumDepositCryptoLimits: Single<CryptoValue> {
        minimumDepositLimits
            .flatMap { [priceService, sourceAsset] fiatValue -> Single<(FiatValue, FiatValue)> in
                let quote = priceService
                    .price(
                        for: sourceAsset,
                        in: fiatValue.currency
                    )
                    .map(\.moneyValue)
                    .map { $0.fiatValue ?? .zero(currency: fiatValue.currencyType) }
                return Single.zip(quote, .just(fiatValue))
            }
            .map { [sourceAsset] (quote: FiatValue, deposit: FiatValue) -> CryptoValue in
                deposit
                    .convertToCryptoValue(
                        exchangeRate: quote,
                        cryptoCurrency: sourceAsset.cryptoCurrency!
                    )
            }
    }

    private var availableBalance: Single<MoneyValue> {
        sourceAccount
            .balance
    }

    private var interestAccountLimits: Single<InterestAccountLimits> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap { [accountLimitsRepository, sourceAsset] fiatCurrency in
                accountLimitsRepository
                    .fetchInterestAccountLimitsForCryptoCurrency(
                        sourceAsset.cryptoCurrency!,
                        fiatCurrency: fiatCurrency
                    )
                    .asObservable()
                    .take(1)
                    .asSingle()
            }
    }

    private let accountLimitsRepository: InterestAccountLimitsRepositoryAPI

    // MARK: - Init

    init(
        requireSecondPassword: Bool,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        accountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve()
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.requireSecondPassword = requireSecondPassword
        self.priceService = priceService
        self.accountLimitsRepository = accountLimitsRepository
    }

    public func assertInputsValid() {
        precondition(sourceAccount is TradingAccount)
        precondition(transactionTarget is InterestAccount)
        precondition(transactionTarget is CryptoAccount)
        precondition(sourceAsset == (transactionTarget as! CryptoAccount).asset)
    }

    public func initializeTransaction()
        -> Single<PendingTransaction>
    {
        Single
            .zip(
                minimumDepositCryptoLimits,
                availableBalance,
                fiatCurrencyService
                    .fiatCurrency
            )
            .map { limits, balance, fiatCurrency -> PendingTransaction in
                let asset = limits.currency
                return PendingTransaction(
                    amount: .zero(currency: asset),
                    available: balance,
                    feeAmount: .zero(currency: asset),
                    feeForFullAvailable: .zero(currency: asset),
                    feeSelection: .init(selectedLevel: .none, availableLevels: [.none]),
                    selectedFiatCurrency: fiatCurrency,
                    minimumLimit: limits.moneyValue
                )
            }
    }

    public func update(
        amount: MoneyValue,
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        availableBalance
            .map { balance in
                pendingTransaction
                    .update(
                        amount: amount,
                        available: balance
                    )
            }
    }

    public func validateAmount(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        availableBalance
            .flatMapCompletable(weak: self) { (self, balance) in
                self.checkIfAvailableBalanceIsSufficient(
                    pendingTransaction,
                    balance: balance
                )
                .andThen(
                    self.checkIfAmountIsBelowMinimumLimit(
                        pendingTransaction
                    )
                )
            }
            .updateTxValidityCompletable(
                pendingTransaction: pendingTransaction
            )
    }

    public func doValidateAll(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        // TODO: Check Terms and Conditions
        validateAmount(pendingTransaction: pendingTransaction)
    }

    public func doBuildConfirmations(
        pendingTransaction: PendingTransaction
    ) -> Single<PendingTransaction> {
        let source = sourceAccount.label
        let destination = transactionTarget.label
        return fiatAmountAndFees(from: pendingTransaction)
            .map { fiatAmount, fiatFees -> PendingTransaction in
                pendingTransaction
                    .update(
                        confirmations: [
                            .source(.init(value: source)),
                            .destination(.init(value: destination)),
                            .feedTotal(
                                .init(
                                    amount: pendingTransaction.amount,
                                    amountInFiat: fiatAmount.moneyValue,
                                    fee: pendingTransaction.feeAmount,
                                    feeInFiat: fiatFees.moneyValue
                                )
                            ),
                            .total(.init(total: pendingTransaction.amount))
                        ]
                    )
            }
    }

    public func execute(
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<TransactionResult> {
        unimplemented()
    }

    public func doPostExecute(
        transactionResult: TransactionResult
    ) -> Completable {
        transactionTarget
            .onTxCompleted(transactionResult)
    }

    public func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }
}
