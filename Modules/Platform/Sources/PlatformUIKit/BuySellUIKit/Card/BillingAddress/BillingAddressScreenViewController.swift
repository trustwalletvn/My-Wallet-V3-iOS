// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxCocoa
import RxRelay
import RxSwift

final class BillingAddressScreenViewController: BaseTableViewController {

    // MARK: - Injected

    private let presenter: BillingAddressScreenPresenter
    private let alertViewPresenter: AlertViewPresenterAPI

    // MARK: - Accessors

    private let keyboardObserver = KeyboardObserver()
    private var keyboardInteractionController: KeyboardInteractionController!
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        presenter: BillingAddressScreenPresenter,
        alertViewPresenter: AlertViewPresenterAPI = resolve()
    ) {
        self.presenter = presenter
        self.alertViewPresenter = alertViewPresenter
        super.init()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
        setupNavigationBar()
        addButton(with: presenter.buttonViewModel)
        keyboardInteractionController = KeyboardInteractionController(
            in: scrollView,
            disablesToolBar: false
        )
        setupTableView()
        setupKeyboardObserver()

        presenter.errorTrigger
            .emit(onNext: { [weak self] in
                guard let self = self else { return }
                self.alertViewPresenter.error(in: self, action: nil)
            })
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
        set(
            barStyle: .darkContent(),
            leadingButtonStyle: .back
        )
        titleViewStyle = .text(value: presenter.title)
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
        tableView.allowsSelection = false
        tableView.contentInset = .init(top: 16, left: 0, bottom: 0, right: 0)
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(SelectionButtonTableViewCell.self)
        tableView.register(TextFieldTableViewCell.self)
        tableView.register(DoubleTextFieldTableViewCell.self)
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self

        presenter.refresh
            .emit(weak: tableView) { $0.reloadData() }
            .disposed(by: disposeBag)
    }

    // MARK: - Navigation

    override func navigationBarLeadingButtonPressed() {
        presenter.previous()
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension BillingAddressScreenViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.presentationDataRelay.value.cellCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let presentationData = presenter.presentationDataRelay.value
        let cellType = presentationData.cellType(for: indexPath.row)
        switch cellType {
        case .textField(let type):
            return textFieldCell(
                for: indexPath.row,
                type: type
            )
        case .doubleTextField(let leadingType, let trailingType):
            return doubleTextFieldCell(
                for: indexPath.row,
                leadingType: leadingType,
                trailingType: trailingType
            )
        case .selectionView:
            return selectionButtonTableViewCell(for: indexPath.row)
        }
    }

    // MARK: - Accessors

    private func textFieldCell(for row: Int, type: TextFieldType) -> UITableViewCell {
        let cell = tableView.dequeue(
            TextFieldTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.setup(
            viewModel: presenter.textFieldViewModelsMap[type]!,
            keyboardInteractionController: keyboardInteractionController,
            scrollView: tableView
        )
        if row == presenter.presentationDataRelay.value.cellCount - 1 {
            cell.bottomInset = 48
        } else {
            cell.bottomInset = 0
        }
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
                leading: presenter.textFieldViewModelsMap[leadingType]!,
                trailing: presenter.textFieldViewModelsMap[trailingType]!
            ),
            keyboardInteractionController: keyboardInteractionController,
            scrollView: tableView
        )
        if row == presenter.presentationDataRelay.value.cellCount - 1 {
            cell.bottomInset = 48
        } else {
            cell.bottomInset = 0
        }
        return cell
    }

    private func selectionButtonTableViewCell(for row: Int) -> UITableViewCell {
        let cell = tableView.dequeue(
            SelectionButtonTableViewCell.self,
            for: IndexPath(row: row, section: 0)
        )
        cell.viewModel = presenter.selectionButtonViewModel
        cell.bottomSpace = 16
        return cell
    }
}
