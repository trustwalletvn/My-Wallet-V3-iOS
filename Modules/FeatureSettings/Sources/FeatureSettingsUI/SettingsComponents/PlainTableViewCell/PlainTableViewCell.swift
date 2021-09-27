// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

struct PlainCellViewModel {
    let title: String
    let accessibilityID: String
    let titleAccessibilityID: String

    init(
        title: String,
        accessibilityID: String,
        titleAccessibilityID: String
    ) {
        self.title = title
        self.accessibilityID = accessibilityID
        self.titleAccessibilityID = titleAccessibilityID
    }
}

final class PlainTableViewCell: UITableViewCell {

    // MARK: - Model

    typealias ViewModel = PlainCellViewModel

    var viewModel: ViewModel! {
        didSet {
            titleLabel.text = viewModel.title
            titleLabel.accessibility = .id(viewModel.titleAccessibilityID)
            accessibility = .id(viewModel.accessibilityID)
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var titleLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .titleText
    }
}
