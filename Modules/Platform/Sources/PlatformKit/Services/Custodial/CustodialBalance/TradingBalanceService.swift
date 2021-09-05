// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol TradingBalanceServiceAPI: AnyObject {
    var balances: Single<CustodialAccountBalanceStates> { get }

    func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState>
    func fetchBalances() -> Single<CustodialAccountBalanceStates>
}

class TradingBalanceService: TradingBalanceServiceAPI {

    // MARK: - Properties

    var balances: Single<CustodialAccountBalanceStates> {
        cachedValue
            .valueSingle
            .catchErrorJustReturn(.absent)
    }

    // MARK: - Private Properties

    private let client: TradingBalanceClientAPI
    private let cachedValue: CachedValue<CustodialAccountBalanceStates>

    // MARK: - Setup

    init(client: TradingBalanceClientAPI = resolve()) {
        self.client = client
        cachedValue = CachedValue(configuration: .periodic(90))
        cachedValue.setFetch(weak: self) { (self) in
            self.client.balance
                .map { response in
                    guard let response = response else {
                        return .absent
                    }
                    return CustodialAccountBalanceStates(response: response)
                }
        }
    }

    // MARK: - Methods

    func balance(for currencyType: CurrencyType) -> Single<CustodialAccountBalanceState> {
        balances
            .map { response -> CustodialAccountBalanceState in
                response[currencyType]
            }
    }

    func fetchBalances() -> Single<CustodialAccountBalanceStates> {
        cachedValue.fetchValue
    }
}
