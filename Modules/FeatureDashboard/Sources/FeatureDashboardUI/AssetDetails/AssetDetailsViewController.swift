// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class AssetDetailsViewController: BaseScreenViewController {

    // MARK: - Private Properties

    private let disposeBag = DisposeBag()

    // MARK: - IBOutlets

    private let tableView: UITableView = .init()
    /// A reload relay that debounces its stream before calling table view to reload its data.
    private let reloadRelay = PublishRelay<Void>()

    // MARK: - Injected

    private let presenter: AssetDetailsScreenPresenter

    // MARK: - Setup

    init(using presenter: AssetDetailsScreenPresenter) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        setupNavigationBar()

        navigationController?.setNavigationBarHidden(true, animated: false)

        presenter.presentationAction
            .emit(onNext: { [weak self] action in
                self?.execute(action: action)
            })
            .disposed(by: disposeBag)

        presenter.setup()
    }

    // MARK: - Setup

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.layoutToSuperview(.leading, .trailing, .top, .bottom)

        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 312
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear

        tableView.registerNibCell(MultiActionTableViewCell.self, in: .platformUIKit)
        tableView.registerNibCell(PriceAlertTableViewCell.self, in: .platformUIKit)
        tableView.registerNibCell(AssetLineChartTableViewCell.self, in: .platformUIKit)
        tableView.register(CurrentBalanceTableViewCell.self)

        tableView.dataSource = self
        tableView.delegate = self

        presenter
            .isScrollEnabled
            .drive(tableView.rx.isScrollEnabled)
            .disposed(by: disposeBag)

        tableView
            .rx
            .itemSelected
            .map(\.row)
            .map(weak: self) { (self, row) in
                self.presenter.cellArrangement[row]
            }
            .bindAndCatch(to: presenter.presenterSelectionRelay)
            .disposed(by: disposeBag)

        reloadRelay
            .startWith(())
            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .subscribe(onNext: { [weak self] _ in
                self?.tableView.reloadData()
            })
            .disposed(by: disposeBag)
    }

    private func setupNavigationBar() {
        set(
            barStyle: presenter.barStyle,
            leadingButtonStyle: presenter.leadingButton,
            trailingButtonStyle: presenter.trailingButton
        )
        titleViewStyle = presenter.titleView
    }

    // MARK: - Actions

    private func execute(action: AssetDetailsScreenPresenter.PresentationAction) {
        switch action {
        case .show:
            reloadRelay.accept(())
        }
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension AssetDetailsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        presenter.cellCount
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: UITableViewCell
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .priceAlert:
            cell = priceAlertCell(for: indexPath)
        case .balance(let account):
            cell = currentBalanceCell(for: indexPath, account: account)
        case .chart:
            cell = assetLineChartCell(for: indexPath, presenter: presenter.lineChartCellPresenter)
        }
        cell.selectionStyle = .none
        return cell
    }

    // MARK: - Accessors

    private func priceAlertCell(for indexPath: IndexPath) -> PriceAlertTableViewCell {
        let cell = tableView.dequeue(PriceAlertTableViewCell.self, for: indexPath)
        cell.currency = presenter.currency
        return cell
    }

    private func multiActionCell(
        for indexPath: IndexPath,
        presenter: MultiActionViewPresenting
    ) -> MultiActionTableViewCell {
        let cell = tableView.dequeue(MultiActionTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func currentBalanceCell(
        for indexPath: IndexPath,
        account: BlockchainAccount
    ) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        switch account {
        case is NonCustodialAccount:
            cell.presenter = presenter.walletBalance?.presenter
        case is TradingAccount:
            cell.presenter = presenter.tradingBalance?.presenter
        case is CryptoInterestAccount:
            cell.presenter = presenter.savingsBalance?.presenter
        default:
            unimplemented("Type \(type(of: account)) not supported.")
        }
        return cell
    }

    private func assetLineChartCell(
        for indexPath: IndexPath,
        presenter: AssetLineChartTableViewCellPresenter
    ) -> AssetLineChartTableViewCell {
        let cell = tableView.dequeue(AssetLineChartTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }
}
