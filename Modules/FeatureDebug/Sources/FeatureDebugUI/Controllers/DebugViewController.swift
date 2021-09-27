// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift
import UIKit

class DebugViewController: UIViewController {

    private static let debugCellIdentifier = "debug.cell.identifier"

    private let disposeBag = DisposeBag()
    private let tableView = UITableView()
    private let viewModel: DebugViewModel

    init(viewModel: DebugViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Debug Settings"
        view.backgroundColor = .white

        setupUI()
        setupBindings()
    }

    private func setupUI() {
        navigationItem.rightBarButtonItem = UIBarButtonItem()
        navigationItem.rightBarButtonItem?.title = "Close"

        view.addSubview(tableView)

        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: Self.debugCellIdentifier)
        tableView.backgroundColor = .white
        tableView.rowHeight = 60
        tableView.separatorInset = .zero
        tableView.tableFooterView = UIView()
        tableView.layoutToSuperview(.top, .bottom, .width, .centerX)
    }

    private func setupBindings() {
        viewModel.items
            .drive(tableView.rx.items(cellIdentifier: Self.debugCellIdentifier)) { _, item, cell in
                cell.textLabel?.text = item.title
                cell.accessoryType = .disclosureIndicator
            }
            .disposed(by: disposeBag)

        tableView.rx
            .modelSelected(DebugItem.self)
            .bindAndCatch(to: viewModel.itemTapped)
            .disposed(by: disposeBag)

        navigationItem.rightBarButtonItem?.rx.tap
            .bindAndCatch(to: viewModel.closeButtonTapped)
            .disposed(by: disposeBag)
    }
}

extension DebugViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension DebugViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        viewModel.closeButtonTapped.accept(())
    }
}
