// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

class AddNewPaymentMethodTableViewCell: UITableViewCell {

    private let buttonView = ButtonView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private

    private func setupUI() {
        buttonView.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(buttonView)
        buttonView.layoutToSuperview(.top, offset: Spacing.outer)
        buttonView.layoutToSuperview(.leading, offset: Spacing.outer)
        buttonView.layoutToSuperview(.bottom, offset: -Spacing.inner)
        buttonView.layoutToSuperview(.right, offset: -Spacing.outer)
        buttonView.layout(dimension: .height, to: 48, relation: .greaterThanOrEqual)
    }

    func configure(viewModel: AddNewPaymentMethodCellModel) {
        buttonView.viewModel = viewModel.buttonModel
    }
}
