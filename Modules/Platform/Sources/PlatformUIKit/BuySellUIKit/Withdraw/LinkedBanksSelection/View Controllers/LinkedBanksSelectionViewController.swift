// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import RxCocoa
import RxDataSources
import RxSwift
import UIKit

enum LinkedBanksSelectionEffects {
    case selection(LinkedBanksSectionItem)
    case closeFlow
    case none
}

class LinkedBanksSelectionViewController: BaseScreenViewController,
    LinkedBanksSelectionViewControllable,
    LinkedBanksSelectionPresentable
{

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<LinkedBanksSectionModel>

    private let disposeBag = DisposeBag()
    private let tableView = UITableView()

    private let closeTriggerred = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // so that we'll be able to listen for system dismissal methods
        navigationController?.presentationController?.delegate = self
        setupNavigationBar()
        setupTableView()
    }

    // MARK: Setup

    func connect(action: Driver<LinkedBanksSelectionAction>) -> Driver<LinkedBanksSelectionEffects> {
        let items: Driver<[LinkedBanksSectionModel]> = action
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
                case .linkedBank(let viewModel):
                    return self.linkedBankCell(for: indexPath, viewModel: viewModel)
                case .addNewBank(let viewModel):
                    return self.addBankCell(for: indexPath, viewModel: viewModel)
                }
            }
        )

        items
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        /// Effects
        let cellSelected = tableView.rx
            .modelSelected(LinkedBanksSectionItem.self)
            .map(LinkedBanksSelectionEffects.selection)
            .asDriver(onErrorJustReturn: .none)

        let closeTriggered = closeTriggerred
            .map { _ in LinkedBanksSelectionEffects.closeFlow }
            .asDriverCatchError()

        return Driver.merge(cellSelected, closeTriggered)
    }

    private func setupTableView() {
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorInset = .zero
        tableView.register(LinkedBankTableViewCell.self)
        tableView.register(AddBankTableViewCell.self)
        view.addSubview(tableView)
        tableView.layoutToSuperview(.top, .bottom, .leading, .trailing)
    }

    private func setupNavigationBar() {
        set(
            barStyle: .darkContent(),
            leadingButtonStyle: .none,
            trailingButtonStyle: .close
        )
        titleViewStyle = .text(value: LocalizationConstants.FiatWithdrawal.LinkedBanks.Navigation.title)
    }

    /// - note: We're overriding this method but we don't call `super` as we want
    /// to be able to handle the dismiss of the controller.
    override func navigationBarTrailingButtonPressed() {
        switch trailingButtonStyle {
        case .close:
            closeTriggerred.onNext(())
        case .none, .processing, .qrCode, .content:
            break
        }
    }

    // MARK: - Private Functions

    private func linkedBankCell(for indexPath: IndexPath, viewModel: BeneficiaryLinkedBankViewModel) -> LinkedBankTableViewCell {
        let cell = tableView.dequeue(LinkedBankTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }

    private func addBankCell(for indexPath: IndexPath, viewModel: AddBankCellModel) -> AddBankTableViewCell {
        let cell = tableView.dequeue(AddBankTableViewCell.self, for: indexPath)
        cell.configure(viewModel: viewModel)
        return cell
    }
}

extension LinkedBanksSelectionViewController: UIAdaptivePresentationControllerDelegate {
    /// Called when a pull-down dismissal happens
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        closeTriggerred.onNext(())
    }
}
