// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

public final class ValidationTextFieldView: TextFieldView {

    // MARK: - Exposed Properties

    private var viewModel: ValidationTextFieldViewModel!

    // MARK: - Private Properties

    private let invalidImageView = UIImageView()
    private var disposeBag = DisposeBag()

    // MARK: - Setup

    override func setup() {
        super.setup()
        setupImageView()
    }

    private func setupImageView() {
        invalidImageView.image = UIImage(named: "validation-error", in: .platformUIKit, compatibleWith: nil)
        invalidImageView.contentMode = .scaleAspectFit
        accessoryView.addSubview(invalidImageView)
        invalidImageView.layout(size: .init(width: 24, height: 20))
        invalidImageView.layoutToSuperview(.centerX, .centerY)
        invalidImageView.horizontalContentCompressionResistancePriority = .penultimateHigh
    }

    public func setup(
        viewModel: ValidationTextFieldViewModel,
        keyboardInteractionController: KeyboardInteractionController
    ) {
        super.setup(viewModel: viewModel, keyboardInteractionController: keyboardInteractionController)
        self.viewModel = viewModel

        // Bind score title to score label
        self.viewModel.accessoryVisibility
            .map(\.defaultAlpha)
            .drive(accessoryView.rx.alpha)
            .disposed(by: disposeBag)
    }
}
