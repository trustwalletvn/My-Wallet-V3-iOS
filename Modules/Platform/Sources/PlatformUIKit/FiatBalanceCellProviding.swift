//
//  FiatBalanceCellProviding.swift
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import UIKit

public protocol FiatBalanceCellProviding {

    func registerFiatBalanceCell(for tableView: UITableView)
    func dequeueReusableFiatBalanceCell(for tableView: UITableView, indexPath: IndexPath, presenter: CurrencyViewPresenter) -> UITableViewCell
}
