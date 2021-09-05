// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RIBs
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

final class SelectPaymentMethodViewController: BaseScreenViewController,
    SelectPaymentMethodPresentable,
    SelectPaymentMethodViewControllable
{

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<PaymentMethodCellModel>

    // MARK: - Views

    private lazy var tableView = UITableView()

    // MARK: - Accessors

    private let disposeBag = DisposeBag()
    private let closeTriggerred = PublishSubject<Void>()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavigationBar()
        setupTableView()
    }

    // MARK: - Connect

    func connect(action: Driver<SelectPaymentMethodAction>) -> Driver<SelectPaymentMethodEffects> {
        let items: Driver<[PaymentMethodCellModel]> = action
            .flatMap { action in
                switch action {
                case .items(let viewModels):
                    return .just(viewModels)
                }
            }

        let dataSource = RxDataSource(
            configureCell: { [weak self] _, _, indexPath, item -> UITableViewCell in
                guard let self = self else { return UITableViewCell() }
                switch item {
                case .linkedCard(let presenter):
                    return self.linkedCardTableViewCell(for: indexPath, presenter: presenter)
                case .account(let presenter):
                    return self.accountTableViewCell(for: indexPath, presenter: presenter)
                case .addNew(let viewModel):
                    return self.addNewTableViewCell(for: indexPath, viewModel: viewModel)
                case .linkedBank(let viewModel):
                    return self.linkedBankTableViewCell(for: indexPath, viewModel: viewModel)
                }
            }
        )

        items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        let closeTriggered = closeTriggerred
            .map { _ in SelectPaymentMethodEffects.closeFlow }
            .asDriverCatchError()

        return closeTriggered
    }

    // MARK: - Navigation

    override func navigationBarTrailingButtonPressed() {
        closeTriggerred.onNext(())
    }

    // MARK: - Private

    private func setupNavigationBar() {
        titleViewStyle = .text(value: LocalizationConstants.SimpleBuy.PaymentMethodSelectionScreen.title)
        setStandardDarkContentStyle()
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.registerNibCell(LinkedCardTableViewCell.self, in: .module)
        tableView.register(FiatCustodialBalanceTableViewCell.self)
        tableView.register(AddNewPaymentMethodTableViewCell.self)
        tableView.register(LinkedBankTableViewCell.self)
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        view.addSubview(tableView)

        tableView.layoutToSuperview(axis: .horizontal)
        tableView.layoutToSuperview(axis: .vertical)
    }

    // MARK: - Private

    private func accountTableViewCell(
        for indexPath: IndexPath,
        presenter: FiatCustodialBalanceViewPresenter
    ) -> UITableViewCell {
        let cell = tableView.dequeue(FiatCustodialBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func linkedCardTableViewCell(
        for indexPath: IndexPath,
        presenter: LinkedCardCellPresenter
    ) -> UITableViewCell {
        let cell = tableView.dequeue(LinkedCardTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func addNewTableViewCell(
        for indexPath: IndexPath,
        viewModel: AddNewPaymentMethodCellModel
    ) -> UITableViewCell {
        let cell = tableView.dequeue(AddNewPaymentMethodTableViewCell.self, for: indexPath)
        cell.configure(viewModel: viewModel)
        return cell
    }

    private func linkedBankTableViewCell(
        for indexPath: IndexPath,
        viewModel: LinkedBankViewModel
    ) -> UITableViewCell {
        let cell = tableView.dequeue(LinkedBankTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }
}

extension SelectPaymentMethodViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView() // removes the last separator line in each section
    }
}
