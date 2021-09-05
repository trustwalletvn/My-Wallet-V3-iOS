// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit
import UIKit

public final class SingleAmountView: UIView, AmountViewable {

    public var view: UIView {
        self
    }

    // MARK: - Properties

    private let fiatAmountLabelView = AmountLabelView()
    private let labeledButtonView = LabeledButtonView<CurrencyLabeledButtonViewModel>()

    private let presenter: SingleAmountPresenter

    public init(presenter: SingleAmountPresenter) {
        self.presenter = presenter
        super.init(frame: UIScreen.main.bounds)

        fiatAmountLabelView.presenter = presenter.amountPresenter.presenter

        setupUI()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init from coder isn't supported")
    }

    private func setupUI() {
        addSubview(fiatAmountLabelView)
        addSubview(labeledButtonView)

        fiatAmountLabelView.layoutToSuperview(.centerX)
        fiatAmountLabelView.layout(dimension: .height, to: 48)
        fiatAmountLabelView.layoutToSuperview(.leading, relation: .greaterThanOrEqual, offset: Spacing.outer)
        fiatAmountLabelView.layoutToSuperview(.trailing, relation: .lessThanOrEqual, offset: -Spacing.outer)
        fiatAmountLabelView.layoutToSuperview(.centerY)

        labeledButtonView.layout(edge: .top, to: .bottom, of: fiatAmountLabelView, offset: Spacing.standard)
        labeledButtonView.layout(to: .centerY, of: fiatAmountLabelView, priority: .penultimateLow)
        labeledButtonView.layoutToSuperview(.centerX)
    }

    public func connect(input: Driver<AmountPresenterInput>) -> Driver<AmountPresenterState> {
        presenter.connect(input: input)
            .map { [weak self] state in
                guard let self = self else { return .empty }
                return self.performEffect(state: state)
            }
    }

    private func performEffect(state: AmountPresenterState) -> AmountPresenterState {
        let limitButtonVisibility: Visibility
        switch state {
        case .showLimitButton(let viewModel):
            labeledButtonView.viewModel = viewModel
            limitButtonVisibility = .visible
        case .empty:
            limitButtonVisibility = .hidden
        case .warning,
             .showSecondaryAmountLabel:
            unimplemented()
        }
        UIView.animate(
            withDuration: 0.15,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseInOut],
            animations: {
                self.labeledButtonView.alpha = limitButtonVisibility.defaultAlpha
            },
            completion: nil
        )
        return state
    }
}
