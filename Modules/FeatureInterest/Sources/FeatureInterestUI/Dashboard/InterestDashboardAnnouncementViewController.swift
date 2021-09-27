// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

public final class InterestDashboardAnnouncementViewController: UIViewController {

    private let tableView = SelfSizingTableView()
    private let presenter: InterestDashboardAnnouncementPresenting

    public init(presenter: InterestDashboardAnnouncementPresenting) {
        self.presenter = presenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override public func loadView() {
        view = UIView()
        view.backgroundColor = .white
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        tableView.reloadData()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.layoutToSuperview(axis: .horizontal, usesSafeAreaLayoutGuide: true)
        tableView.layoutToSuperview(axis: .vertical, usesSafeAreaLayoutGuide: true)
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(AnnouncementTableViewCell.self)
        tableView.register(BadgeNumberedTableViewCell.self)
        tableView.registerNibCell(ButtonsTableViewCell.self, in: .platformUIKit)
        tableView.register(LineItemTableViewCell.self)
        tableView.register(FooterTableViewCell.self)
        tableView.separatorColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension InterestDashboardAnnouncementViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        presenter.cellCount
    }

    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: UITableViewCell
        let type = presenter.cellArrangement[indexPath.row]
        switch type {
        case .announcement(let viewModel):
            cell = announcement(for: indexPath, viewModel: viewModel)
        case .numberedItem(let viewModel):
            cell = numberedCell(for: indexPath, viewModel: viewModel)
        case .buttons(let buttons):
            cell = buttonsCell(for: indexPath, buttons: buttons)
        case .item(let presenter):
            cell = lineItemCell(for: indexPath, presenter: presenter)
        case .footer(let presenter):
            cell = footerCell(for: indexPath, presenter: presenter)
        }
        return cell
    }

    // MARK: - Accessors

    private func announcement(for indexPath: IndexPath, viewModel: AnnouncementCardViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(AnnouncementTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }

    private func numberedCell(for indexPath: IndexPath, viewModel: BadgeNumberedItemViewModel) -> UITableViewCell {
        let cell = tableView.dequeue(BadgeNumberedTableViewCell.self, for: indexPath)
        cell.viewModel = viewModel
        return cell
    }

    private func lineItemCell(for indexPath: IndexPath, presenter: LineItemCellPresenting) -> UITableViewCell {
        let cell = tableView.dequeue(LineItemTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func footerCell(for indexPath: IndexPath, presenter: FooterTableViewCellPresenter) -> FooterTableViewCell {
        let cell = tableView.dequeue(FooterTableViewCell.self, for: indexPath)
        cell.presenter = presenter
        return cell
    }

    private func buttonsCell(for indexPath: IndexPath, buttons: [ButtonViewModel]) -> UITableViewCell {
        let cell = tableView.dequeue(ButtonsTableViewCell.self, for: indexPath)
        cell.models = buttons
        return cell
    }
}
