// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public final class ButtonsTableViewCell: UITableViewCell {

    public var models: [ButtonViewModel] = [] {
        willSet {
            stackView.removeSubviews()
        }
        didSet {
            models.forEach { addButton(with: $0) }
        }
    }

    @IBOutlet private var stackView: UIStackView!

    private func addButton(with viewModel: ButtonViewModel) {
        let buttonView = ButtonView()
        buttonView.viewModel = viewModel
        stackView.addArrangedSubview(buttonView)
        buttonView.layout(dimension: .height, to: 48)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        models = []
    }
}
