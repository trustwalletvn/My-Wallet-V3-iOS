// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit

final class CardDetailsScreenViewController: BaseTableViewController {

    // MARK: - Injected

    private let keyboardObserver = KeyboardObserver()
    private let presenter: CardDetailsScreenPresenter
    private let alertPresenter: AlertViewPresenterAPI

    private var keyboardInteractionController: KeyboardInteractionController!
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        presenter: CardDetailsScreenPresenter,
        alertPresenter: AlertViewPresenterAPI = resolve()
    ) {
        self.presenter = presenter
        self.alertPresenter = alertPresenter
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupNavigationBar()
        keyboardInteractionController = KeyboardInteractionController(
            in: scrollView,
            disablesToolBar: false
        )
        setupTableView()
        setupKeyboardObserver()

        presenter.error
            .emit(weak: self) { (self, error) in
                switch error {
                case .cardAlreadySaved:
                    typealias LocalizedString = LocalizationConstants.CardDetailsScreen.Alert
                    self.alertPresenter.notify(
                        content: .init(
                            title: LocalizedString.title,
                            message: LocalizedString.message
                        ),
                        in: self
                    )
                case .generic:
                    self.alertPresenter.error(in: self, action: nil)
                }
            }
            .disposed(by: disposeBag)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.viewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        keyboardObserver.setup()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.remove()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        presenter.viewDidDisappear()
    }

    private func setupNavigationBar() {
        titleViewStyle = .text(value: presenter.title)
        setStandardDarkContentStyle()
    }

    private func setupKeyboardObserver() {
        keyboardObserver.state
            .bindAndCatch(weak: self) { (self, state) in
                switch state.visibility {
                case .visible:
                    self.contentBottomConstraint.constant = -(state.payload.height - self.view.safeAreaInsets.bottom)
                case .hidden:
                    self.contentBottomConstraint.constant = 0
                }
                self.view.layoutIfNeeded()
            }
            .disposed(by: disposeBag)
    }

    private func setupTableView() {
        tableView.selfSizingBehaviour = .fill
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(TextFieldTableViewCell.self)
        tableView.register(DoubleTextFieldTableViewCell.self)
        tableView.register(NoticeTableViewCell.self)
        tableView.registerNibCell(ButtonsTableViewCell.self, in: .module)
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
    }

    // MARK: - Navigation

    override func navigationBarTrailingButtonPressed() {
        presenter.previous()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension CardDetailsScreenViewController: UITableViewDelegate, UITableViewDataSource {

    private func textFieldCell(for row: Int, type: TextFieldType) -> UITableViewCell {
        let cell = tableView.dequeue(
            TextFieldTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.setup(
            viewModel: presenter.textFieldViewModelByType[type]!,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: tableView
        )
        return cell
    }

    private func doubleTextFieldCell(
        for row: Int,
        leadingType: TextFieldType,
        trailingType: TextFieldType
    ) -> UITableViewCell {
        let cell = tableView.dequeue(
            DoubleTextFieldTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.setup(
            viewModel: .init(
                leading: presenter.textFieldViewModelByType[leadingType]!,
                trailing: presenter.textFieldViewModelByType[trailingType]!
            ),
            keyboardInteractionController: keyboardInteractionController,
            scrollView: tableView
        )
        return cell
    }

    private func buttonTableViewCell(
        for row: Int,
        viewModel: ButtonViewModel
    ) -> UITableViewCell {
        let cell = tableView.dequeue(
            ButtonsTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.models = [viewModel]
        return cell
    }

    private func privacyNoticeCell(for type: CardDetailsScreenPresenter.CellType) -> UITableViewCell {
        let cell = tableView.dequeue(
            NoticeTableViewCell.self,
            for: IndexPath(row: type.row, section: 0)
        )
        cell.viewModel = presenter.noticeViewModel
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.rowCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellType = CardDetailsScreenPresenter.CellType(indexPath.row)
        switch cellType {
        case .button:
            return buttonTableViewCell(
                for: cellType.row,
                viewModel: presenter.buttonViewModel
            )
        case .textField(let type):
            return textFieldCell(for: cellType.row, type: type)
        case .doubleTextField(let leadingType, let trailingType):
            return doubleTextFieldCell(
                for: cellType.row,
                leadingType: leadingType,
                trailingType: trailingType
            )
        case .privacyNotice:
            return privacyNoticeCell(for: cellType)
        }
    }
}
