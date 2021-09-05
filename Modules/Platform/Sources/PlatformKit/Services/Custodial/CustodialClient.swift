// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift
import ToolKit

public protocol TradingBalanceClientAPI: AnyObject {
    var balance: Single<CustodialBalanceResponse?> { get }

    func balance(for currencyType: CurrencyType) -> Single<CustodialBalanceResponse?>
}

final class CustodialClient: TradingBalanceClientAPI,
    CustodialPaymentAccountClientAPI,
    CustodialPendingDepositClientAPI
{

    // MARK: - Types

    private enum Path {
        static let withdrawal = ["payments", "withdrawals"]
        static let paymentAccount = ["payments", "accounts", "simplebuy"]
        static let custodialBalance = ["accounts", "simplebuy"]
    }

    // MARK: - Properties

    var balance: Single<CustodialBalanceResponse?> {
        let path = Path.custodialBalance
        let request = requestBuilder.get(
            path: path,
            authenticated: true
        )!
        return networkAdapter
            .performOptional(
                request: request,
                responseType: CustodialBalanceResponse.self,
                errorResponseType: NabuNetworkError.self
            )
    }

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - CustodialPendingDepositClientAPI

    func createPendingDeposit(body: CreatePendingDepositRequestBody) -> Completable {
        let request = requestBuilder.post(
            path: Path.withdrawal,
            body: try? body.encode(),
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }

    // MARK: - TradingBalanceClientAPI

    func balance(for currencyType: CurrencyType) -> Single<CustodialBalanceResponse?> {
        balance
    }

    // MARK: - CustodialPaymentAccountClientAPI

    func custodialPaymentAccount(for cryptoCurrency: CryptoCurrency) -> Single<PaymentAccount.Response> {
        struct Payload: Encodable {
            let currency: String
        }

        let payload = Payload(currency: cryptoCurrency.code)
        let request = requestBuilder.put(
            path: Path.paymentAccount,
            body: try? payload.encode(),
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
}
