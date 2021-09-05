// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A table view that contains a numbered list of instructions
public final class InstructionTableView: UITableView {

    // MARK: - Properties

    public var viewModels: [InstructionCellViewModel] = [] {
        didSet {
            reloadData()
        }
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        delegate = self
        dataSource = self
        separatorStyle = .none
        estimatedRowHeight = 80
        rowHeight = UITableView.automaticDimension
        allowsSelection = false
        registerNibCell(InstructionTableViewCell.self, in: .module)
        tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 32))
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension InstructionTableView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModels.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: InstructionTableViewCell = tableView.dequeue(InstructionTableViewCell.self, for: indexPath)
        cell.viewModel = viewModels[indexPath.row]
        return cell
    }
}
