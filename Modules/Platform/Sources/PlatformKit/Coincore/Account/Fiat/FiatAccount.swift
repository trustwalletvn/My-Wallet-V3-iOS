// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol FiatAccount: SingleAccount {
    var fiatCurrency: FiatCurrency { get }
    var canWithdrawFunds: Single<Bool> { get }
}

extension FiatAccount {
    public var currencyType: CurrencyType {
        fiatCurrency.currency
    }

    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }
}
