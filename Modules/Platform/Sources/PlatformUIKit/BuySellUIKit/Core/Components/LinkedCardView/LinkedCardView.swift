// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

final class LinkedCardView: UIView {

    // MARK: - Public Properties

    var viewModel: LinkedCardViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            guard let viewModel = viewModel else { return }

            badgeImageView.viewModel = viewModel.badgeImageViewModel

            viewModel.nameContent
                .drive(cardNameLabel.rx.content)
                .disposed(by: disposeBag)

            viewModel.limitContent
                .drive(cardLimitLabel.rx.content)
                .disposed(by: disposeBag)
        }
    }

    // MARK: - Rx

    private var disposeBag = DisposeBag()

    // MARK: - Private IBOutlets

    @IBOutlet private var badgeImageView: BadgeImageView!
    @IBOutlet private var cardNameLabel: UILabel!
    @IBOutlet private var cardLimitLabel: UILabel!

    // MARK: - Setup

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        fromNib(in: .module)
        clipsToBounds = true
    }
}
