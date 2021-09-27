// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import stellarsdk

protocol StellarHistoricalTransactionServiceAPI {
    func transactions(accountID: String, size: Int) -> Single<[StellarHistoricalTransaction]>
    func transaction(accountID: String, operationID: String) -> Single<StellarHistoricalTransaction>
}

final class StellarHistoricalTransactionService: StellarHistoricalTransactionServiceAPI {

    // MARK: - Private Properties

    private var operationsService: Single<stellarsdk.OperationsService> {
        sdk.map(\.operations)
    }

    private var sdk: Single<stellarsdk.StellarSDK> {
        configurationService
            .configuration
            .map(\.sdk)
    }

    // MARK: - Private Properties

    private let configurationService: StellarConfigurationAPI
    private let disposeBag = DisposeBag()

    init(configurationService: StellarConfigurationAPI = resolve()) {
        self.configurationService = configurationService
    }

    func transactions(accountID: String, size: Int) -> Single<[StellarHistoricalTransaction]> {
        operationsService
            .flatMap { operationsService -> Single<PageResponse<OperationResponse>> in
                operationsService.transactions(accountID: accountID, size: size)
            }
            .map { response -> [StellarHistoricalTransaction] in
                response
                    .records
                    .compactMap { $0.buildOperation(accountID: accountID) }
            }
            .catchError { error in
                switch error {
                case stellarsdk.HorizonRequestError.notFound:
                    return .just([])
                default:
                    throw error
                }
            }
    }

    func transaction(accountID: String, operationID: String) -> Single<StellarHistoricalTransaction> {
        operationsService
            .flatMap { operationsService -> Single<OperationResponse> in
                operationsService.transaction(operationID: operationID)
            }
            .map { response -> StellarHistoricalTransaction? in
                response.buildOperation(accountID: accountID)
            }
            .onNil(error: StellarNetworkError.parsingError)
    }
}

extension stellarsdk.OperationsService {

    func transaction(operationID: String) -> Single<OperationResponse> {
        Single<OperationResponse>
            .create(weak: self) { (self, observer) -> Disposable in
                self.getOperationDetails(
                    operationId: operationID,
                    join: "transactions",
                    response: { response in
                        switch response {
                        case .success(let details):
                            observer(.success(details))
                        case .failure(let error):
                            observer(.error(error))
                        }
                    }
                )
                return Disposables.create()
            }
    }

    func transactions(accountID: String, size: Int) -> Single<PageResponse<OperationResponse>> {
        Single<PageResponse<OperationResponse>>
            .create(weak: self) { (self, observer) -> Disposable in
                self.getOperations(
                    forAccount: accountID,
                    order: .descending,
                    limit: size,
                    join: "transactions",
                    response: { response in
                        switch response {
                        case .success(details: let payload):
                            observer(.success(payload))
                        case .failure(error: let horizonError):
                            observer(.error(horizonError.toStellarServiceError()))
                        }
                    }
                )
                return Disposables.create()
            }
    }
}

extension OperationResponse {
    fileprivate func buildOperation(accountID: String) -> StellarHistoricalTransaction? {
        guard let transaction = transaction else {
            return nil
        }

        switch operationType {
        case .accountCreated:
            guard let self = self as? AccountCreatedOperationResponse else {
                return nil
            }
            let data = self.accountCreated(
                accountID: accountID,
                feeCharged: Int(transaction.feeCharged ?? "0"),
                memo: transaction.memo?.textMemo
            )
            return .accountCreated(data)

        case .payment:
            guard let self = self as? PaymentOperationResponse else {
                return nil
            }
            let data = self.payment(
                accountID: accountID,
                feeCharged: Int(transaction.feeCharged ?? "0"),
                memo: transaction.memo?.textMemo
            )
            return .payment(data)

        case .accountMerge,
             .allowTrust,
             .bumpSequence,
             .changeTrust,
             .createPassiveSellOffer,
             .inflation,
             .manageBuyOffer,
             .manageData,
             .manageSellOffer,
             .pathPayment,
             .pathPaymentStrictSend,
             .setOptions,
             .createClaimableBalance,
             .claimClaimableBalance,
             .endSponsoringFutureReserves,
             .revokeSponsorship,
             .beginSponsoringFutureReserves,
             .clawback,
             .clawbackClaimableBalance,
             .setTrustLineFlags:
            return nil
        }
    }
}

extension AccountCreatedOperationResponse {
    fileprivate func accountCreated(accountID: String, feeCharged: Int?, memo: String?) -> StellarHistoricalTransaction.AccountCreated {
        StellarHistoricalTransaction.AccountCreated(
            identifier: id,
            pagingToken: pagingToken,
            funder: funder,
            account: account,
            direction: funder == accountID ? .credit : .debit,
            balance: startingBalance,
            sourceAccountID: sourceAccount,
            transactionHash: transactionHash,
            createdAt: createdAt,
            fee: funder == accountID ? feeCharged : nil,
            memo: memo
        )
    }
}

extension PaymentOperationResponse {
    fileprivate func payment(accountID: String, feeCharged: Int?, memo: String?) -> StellarHistoricalTransaction.Payment {
        StellarHistoricalTransaction.Payment(
            identifier: id,
            pagingToken: pagingToken,
            fromAccount: from,
            toAccount: to,
            direction: from == accountID ? .credit : .debit,
            amount: amount,
            transactionHash: transactionHash,
            createdAt: createdAt,
            fee: from == accountID ? feeCharged : nil,
            memo: memo
        )
    }
}

extension stellarsdk.Memo {
    fileprivate var textMemo: String? {
        switch self {
        case .text(let text):
            return text
        case .hash, .id, .none, .returnHash:
            return nil
        }
    }
}
