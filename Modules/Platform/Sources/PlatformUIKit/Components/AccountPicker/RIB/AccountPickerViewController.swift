// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs
import RxCocoa
import RxDataSources
import RxRelay
import RxSwift
import ToolKit

protocol AccountPickerViewControllable: ViewControllable {
    func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects>
}

final class AccountPickerViewController: BaseScreenViewController, AccountPickerViewControllable {

    // MARK: - Types

    private typealias RxDataSource = RxTableViewSectionedReloadDataSource<AccountPickerSectionViewModel>

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()
    private let shouldOverrideNavigationEffects: Bool
    private let tableView = UITableView(frame: .zero, style: .grouped)
    private let headerRelay = BehaviorRelay<HeaderBuilder?>(value: nil)
    private let backButtonRelay = PublishRelay<Void>()
    private let closeButtonRelay = PublishRelay<Void>()

    private lazy var dataSource: RxDataSource = {
        RxDataSource(configureCell: { [weak self] _, _, indexPath, item in
            guard let self = self else { return UITableViewCell() }
            let cell: UITableViewCell
            switch item.presenter {
            case .button(let viewModel):
                cell = self.buttonTableViewCell(for: indexPath, viewModel: viewModel)
            case .linkedBankAccount(let presenter):
                cell = self.linkedBankCell(for: indexPath, presenter: presenter)
            case .accountGroup(let presenter):
                cell = self.totalBalanceCell(for: indexPath, presenter: presenter)
            case .singleAccount(let presenter):
                cell = self.balanceCell(for: indexPath, presenter: presenter)
            }
            cell.selectionStyle = .none
            return cell
        })
    }()

    private lazy var setupTableView: Void = {
        tableView.backgroundColor = .white
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.separatorColor = .clear
        tableView.alwaysBounceVertical = true
        tableView.register(LinkedBankAccountTableViewCell.self)
        tableView.register(CurrentBalanceTableViewCell.self)
        tableView.registerNibCell(AccountGroupBalanceTableViewCell.self, in: .module)
        tableView.registerNibCell(ButtonsTableViewCell.self, in: .module)
    }()

    init(shouldOverrideNavigationEffects: Bool) {
        self.shouldOverrideNavigationEffects = shouldOverrideNavigationEffects
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { unimplemented() }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        _ = setupTableView
        view.addSubview(tableView)
        tableView.layoutToSuperview(.top, .bottom, .leading, .trailing)
    }

    // MARK: - Methods

    func connect(state: Driver<AccountPickerPresenter.State>) -> Driver<AccountPickerInteractor.Effects> {
        disposeBag = DisposeBag()
        tableView.delegate = self

        let stateWait: Driver<AccountPickerPresenter.State> =
            rx.viewDidLoad
                .asDriver()
                .flatMap { _ in
                    state
                }

        stateWait
            .map(\.navigationModel)
            .drive(weak: self) { (self, model) in
                self.titleViewStyle = model.titleViewStyle
                self.set(
                    barStyle: model.barStyle,
                    leadingButtonStyle: model.leadingButton,
                    trailingButtonStyle: model.trailingButton
                )
            }
            .disposed(by: disposeBag)

        stateWait.map(\.headerModel)
            .map { AccountPickerHeaderBuilder(headerType: $0) }
            .drive(headerRelay)
            .disposed(by: disposeBag)

        stateWait.map(\.sections)
            .drive(tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        let modelSelected = tableView.rx.modelSelected(AccountPickerCellItem.self)
            .compactMap(\.account)
            .map { AccountPickerInteractor.Effects.select($0) }
            .asDriver(onErrorJustReturn: .none)

        let backButtonEffect = backButtonRelay
            .map { AccountPickerInteractor.Effects.back }
            .asDriverCatchError()

        let closeButtonEffect = closeButtonRelay
            .map { AccountPickerInteractor.Effects.closed }
            .asDriverCatchError()

        return .merge(modelSelected, backButtonEffect, closeButtonEffect)
    }

    override func navigationBarLeadingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarLeadingButtonPressed()
            return
        }
        switch leadingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        case .back:
            backButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    override func navigationBarTrailingButtonPressed() {
        guard shouldOverrideNavigationEffects else {
            super.navigationBarTrailingButtonPressed()
            return
        }
        switch trailingButtonStyle {
        case .close:
            closeButtonRelay.accept(())
        default:
            super.navigationBarLeadingButtonPressed()
        }
    }

    // MARK: - Private Methods

    private func linkedBankCell(
        for indexPath: IndexPath,
        presenter: LinkedBankAccountCellPresenter
    ) -> UITableViewCell {
        let cell = tableView.dequeue(LinkedBankAccountTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func balanceCell(
        for indexPath: IndexPath,
        presenter: CurrentBalanceCellPresenting
    ) -> UITableViewCell {
        let cell = tableView.dequeue(CurrentBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func totalBalanceCell(
        for indexPath: IndexPath,
        presenter: AccountGroupBalanceCellPresenter
    ) -> AccountGroupBalanceTableViewCell {
        let cell = tableView.dequeue(AccountGroupBalanceTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func buttonTableViewCell(
        for indexPath: IndexPath,
        viewModel: ButtonViewModel
    ) -> UITableViewCell {
        let cell = tableView.dequeue(
            ButtonsTableViewCell.self,
            for: indexPath
        )
        cell.models = [viewModel]
        return cell
    }
}

extension AccountPickerViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        return headerRelay.value?.view(fittingWidth: view.bounds.width, customHeight: nil)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard section == 0 else { return 0 }
        return headerRelay.value?.defaultHeight ?? 0
    }
}
