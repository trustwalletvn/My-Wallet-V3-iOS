// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift

final class SwitchTableViewCell: UITableViewCell {

    // MARK: - Public Properites

    var presenter: SwitchCellPresenting! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else { return }
            switchView.viewModel = presenter.switchViewPresenting.viewModel
            presenter.labelContentPresenting.state
                .compactMap { $0 }
                .bindAndCatch(to: rx.content)
                .disposed(by: disposeBag)

            accessibility = presenter.accessibility
        }
    }

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - Private IBOutlets

    @IBOutlet fileprivate var switchView: SwitchView!
    @IBOutlet fileprivate var titleLabel: UILabel!

    // MARK: - Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .titleText
    }
}

// MARK: - Rx

extension Reactive where Base: SwitchTableViewCell {

    var content: Binder<LabelContent.State.Presentation> {
        Binder(base) { view, state in
            switch state {
            case .loading:
                break
            case .loaded(next: let value):
                view.titleLabel.content = value.labelContent
            }
        }
    }
}
