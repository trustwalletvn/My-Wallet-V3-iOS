// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import UIKit

class MultiBadgeView: UIView {

    // MARK: Private Properties

    private let stackView = UIStackView()

    private var disposeBag = DisposeBag()

    private var horizontalConstraints: Axis.Constraints?
    private var verticalConstraints: Axis.Constraints?
    private var heightConstraint: NSLayoutConstraint!

    // MARK: - Public Properties

    var model: MultiBadgeViewModel! {
        willSet {
            disposeBag = DisposeBag()
            stackView.removeSubviews()
        }
        didSet {
            guard let model = model else { return }
            model
                .badges
                .drive(onNext: { [weak self] models in
                    self?.stackView.removeSubviews()
                    models.forEach { self?.add($0) }
                    self?.stackView.addArrangedSubview(UIView())
                })
                .disposed(by: disposeBag)

            model
                .layoutMargins
                .drive(onNext: { [weak self] layoutMargins in
                    self?.horizontalConstraints?.leading.constant = layoutMargins.left
                    self?.horizontalConstraints?.trailing.constant = -layoutMargins.right
                    self?.verticalConstraints?.leading.constant = layoutMargins.top
                    self?.verticalConstraints?.trailing.constant = -layoutMargins.bottom
                })
                .disposed(by: disposeBag)

            model
                .height
                .drive(onNext: { [weak self] height in
                    self?.heightConstraint?.constant = height
                })
                .disposed(by: disposeBag)
        }
    }

    // MARK: Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: Private Methods

    private func add(_ presenter: BadgeAssetPresenting) {
        let badge = BadgeView()
        badge.contentHuggingPriority = (.defaultHigh, .defaultHigh)
        stackView.addArrangedSubview(badge)
        badge.layout(edges: .height, to: stackView)
        presenter.state
            .compactMap { $0 }
            .bindAndCatch(to: badge.rx.viewModel)
            .disposed(by: disposeBag)
    }

    private func setup() {
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        addSubview(stackView)
        heightConstraint = stackView.layout(dimension: .height, to: 32, priority: .defaultLow)
        horizontalConstraints = stackView.layoutToSuperview(axis: .horizontal)
        verticalConstraints = stackView.layoutToSuperview(axis: .vertical)
    }
}

extension Reactive where Base: MultiBadgeView {
    var viewModel: Binder<MultiBadgeViewModel> {
        Binder(base) { view, model in
            view.model = model
        }
    }
}
