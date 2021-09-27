// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

class InternalFeatureFlagViewController: UIViewController {
    private static let featureFlagCellIdentifier = "internal.feature.flag.cell.identifier"

    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private let viewModel: InternalFeatureFlagViewModel

    init(viewModel: InternalFeatureFlagViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Internal Feature Flags"
        view.backgroundColor = .white

        setupUI()
        setupBindings()
    }

    private func setupUI() {
        view.addSubview(tableView)

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.featureFlagCellIdentifier)
        tableView.backgroundColor = .white
        tableView.rowHeight = 60
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.layoutToSuperview(.top, .bottom, .width, .centerX)
    }

    private func setupBindings() {

        viewModel.items.drive(tableView.rx.items(cellIdentifier: Self.featureFlagCellIdentifier)) { _, item, cell in
            cell.textLabel?.text = item.title
            cell.accessoryType = item.enabled ? UITableViewCell.AccessoryType.checkmark : .none
        }
        .disposed(by: disposeBag)

        tableView.rx.modelSelected(InternalFeatureItem.self)
            .map(InternalFeatureAction.selected)
            .bindAndCatch(to: viewModel.action)
            .disposed(by: disposeBag)
    }
}
