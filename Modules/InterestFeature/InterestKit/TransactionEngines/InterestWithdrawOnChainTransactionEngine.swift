// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CombineExt
import DIKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

public final class InterestWithdrawOnChainTransactionEngine: OnChainTransactionEngine,
    InterestTransactionEngine
{

    // MARK: - InterestTransactionEngine

    public var minimumDepositLimits: Single<FiatValue> {
        unimplemented()
    }

    // MARK: - OnChainTransactionEngine

    public var askForRefreshConfirmation: (AskForRefreshConfirmation)!

    public var requireSecondPassword: Bool

    public var transactionTarget: TransactionTarget!
    public var sourceAccount: BlockchainAccount!

    // MARK: - InterestTransactionEngine

    public let priceService: PriceServiceAPI
    public let fiatCurrencyService: FiatCurrencyServiceAPI

    // MARK: - Private Properties

    private var availableBalance: Single<MoneyValue> {
        sourceAccount
            .balance
    }

    private var minimumLimit: Single<MoneyValue> {
        feeCache
            .fetchValue
            .map(\.[minimumAmount: sourceAsset])
    }

    private var fee: Single<MoneyValue> {
        feeCache
            .fetchValue
            .map(\.[fee: sourceAsset])
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

    private let feeCache: CachedValue<CustodialTransferFee>
    private let transferRepository: CustodialTransferRepositoryAPI
    private let accountLimitsRepository: InterestAccountLimitsRepositoryAPI

    // MARK: - Init

    init(
        requireSecondPassword: Bool,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        accountLimitsRepository: InterestAccountLimitsRepositoryAPI = resolve(),
        transferRepository: CustodialTransferRepositoryAPI = resolve()
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.requireSecondPassword = requireSecondPassword
        self.priceService = priceService
        self.accountLimitsRepository = accountLimitsRepository
        self.transferRepository = transferRepository
        feeCache = CachedValue(configuration: .periodic(20))
        feeCache.setFetch(weak: self) { (self) -> Single<CustodialTransferFee> in
            self.transferRepository
                .feesAndLimitsForInterest()
                .asObservable()
                .take(1)
                .asSingle()
        }
    }

    public func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(transactionTarget is NonCustodialAccount)
        precondition(sourceAccount is InterestAccount)
    }

    public func initializeTransaction()
        -> Single<PendingTransaction>
    {
        Single.zip(
            fiatCurrencyService
                .fiatCurrency,
            fee,
            availableBalance,
            minimumLimit,
            interestAccountLimits
                .map(\.maxWithdrawalAmount)
                .map(\.moneyValue)
        )
        .map { [sourceAsset] fiatCurrency, fee, balance, minimum, maximum -> PendingTransaction in
            PendingTransaction(
                amount: .zero(currency: sourceAsset),
                available: balance,
                feeAmount: fee,
                feeForFullAvailable: .zero(currency: sourceAsset),
                feeSelection: .empty(asset: sourceAsset),
                selectedFiatCurrency: fiatCurrency,
                minimumLimit: minimum,
                maximumLimit: maximum
            )
        }
    }

    public func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
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
                            // TODO: Account for memo if the transactionTarget
                            // has a memo.
                            .total(.init(total: pendingTransaction.amount))
                        ]
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
        validateAmount(pendingTransaction: pendingTransaction)
    }

    public func execute(
        pendingTransaction: PendingTransaction,
        secondPassword: String
    ) -> Single<TransactionResult> {
        unimplemented()
    }
}
