//
//  FiatBalanceInteracting.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import RxSwift

public protocol FiatBalancesInteracting {

    var hasBalances: Observable<Bool> { get }

    func reloadBalances()
}
