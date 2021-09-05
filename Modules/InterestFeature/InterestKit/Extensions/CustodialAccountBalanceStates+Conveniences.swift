// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension CustodialAccountBalanceStates {
    init(balances: InterestAccountBalances) {
        let balances = balances.balances
            .reduce(into: [CurrencyType: CustodialAccountBalanceState]()) { result, item in
                guard let cryptoCurrency = CryptoCurrency(code: item.key) else {
                    return
                }
                guard let accountBalance = CustodialAccountBalance(
                    currency: cryptoCurrency.currency,
                    response: item.value
                ) else {
                    return
                }
                result[cryptoCurrency.currency] = .present(accountBalance)
            }
        self = .init(balances: balances)
    }
}
