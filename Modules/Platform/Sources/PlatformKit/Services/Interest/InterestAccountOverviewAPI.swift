//
//  SavingsServiceAPI.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Foundation
import RxSwift

public protocol InterestAccountOverviewAPI {
    func balance(for currency: CryptoCurrency) -> Single<CustodialAccountBalanceState>
    func rate(for currency: CryptoCurrency) -> Single<Double>
}
