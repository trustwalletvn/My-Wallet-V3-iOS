// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public final class LabelTableViewCell: UITableViewCell {

    // MARK: - Exposed Properites

    public var content: LabelContent! {
        willSet {
            presenter = nil
        }
        didSet {
            guard content != nil else { return }
            titleLabel.content = content
            titleShimmeringView.stop()
        }
    }

    public var presenter: LabelContentPresenting! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard presenter != nil else { return }
            presenter.state
                .bindAndCatch(to: rx.titleContent)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - IBOutlets

    fileprivate let titleLabel: UILabel = .init()
    fileprivate var titleShimmeringView: ShimmeringView!

    override public func prepareForReuse() {
        super.prepareForReuse()
        content = .empty
    }

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        build()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    private func build() {
        selectionStyle = .none
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        titleLabel.layoutToSuperview(axis: .horizontal, offset: 24)
        titleLabel.layoutToSuperview(axis: .vertical, offset: 16)
        let height = titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 16)
        height.priority = .penultimateHigh
        height.isActive = true

        titleShimmeringView = ShimmeringView(
            in: contentView,
            anchorView: titleLabel,
            size: .init(width: 150, height: 24)
        )
    }
}

extension Reactive where Base: LabelTableViewCell {

    fileprivate var titleContent: Binder<LabelContent.State.Presentation> {
        Binder(base) { view, state in
            switch state {
            case .loading:
                UIView.animate(
                    withDuration: 0.5,
                    animations: { view.titleShimmeringView.start() }
                )
            case .loaded(next: let value):
                UIView.animate(
                    withDuration: 0.2,
                    delay: 0.0,
                    options: .transitionCrossDissolve,
                    animations: {
                        view.titleLabel.content = value.labelContent
                        view.titleShimmeringView.stop()
                    }
                )
            }
        }
    }
}
