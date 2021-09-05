// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxCocoa
import RxSwift

final class RecoveryPhraseView: UIView {

    // MARK: - Public Properties

    var viewModel: RecoveryPhraseViewModel! {
        willSet {
            disposeBag = DisposeBag()
        }
        didSet {
            viewModel.words
                .bindAndCatch(to: rx.mnemonicContent)
                .disposed(by: disposeBag)

            clipboardButtonView.viewModel = viewModel.copyButtonViewModel
        }
    }

    // MARK: Private IBOutlets (UILabel)

    @IBOutlet private var firstLabel: UILabel!
    @IBOutlet private var secondLabel: UILabel!
    @IBOutlet private var thirdLabel: UILabel!
    @IBOutlet private var fourthLabel: UILabel!
    @IBOutlet private var fifthLabel: UILabel!
    @IBOutlet private var sixthLabel: UILabel!
    @IBOutlet private var seventhLabel: UILabel!
    @IBOutlet private var eigthLabel: UILabel!
    @IBOutlet private var ninthLabel: UILabel!
    @IBOutlet private var tenthLabel: UILabel!
    @IBOutlet private var eleventhLabel: UILabel!
    @IBOutlet private var twelfthLabel: UILabel!

    // MARK: - Private IBOutlets (Other)

    @IBOutlet private var numberedLabels: [UILabel]!
    @IBOutlet private var clipboardButtonView: ButtonView!

    // MARK: - Private Properties

    fileprivate var labels: [UILabel] {
        [
            firstLabel,
            secondLabel,
            thirdLabel,
            fourthLabel,
            fifthLabel,
            sixthLabel,
            seventhLabel,
            eigthLabel,
            ninthLabel,
            tenthLabel,
            eleventhLabel,
            twelfthLabel
        ]
    }

    private var disposeBag = DisposeBag()

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
        fromNib(in: Bundle(for: Self.self))
        clipsToBounds = true
        numberedLabels.forEach { $0.textColor = .mutedText }
        layer.cornerRadius = 8.0
        backgroundColor = .background
    }
}

extension Reactive where Base: RecoveryPhraseView {
    fileprivate var mnemonicContent: Binder<[LabelContent]> {
        Binder(base) { view, payload in
            payload.enumerated().forEach { value in
                view.labels[value.0].content = value.1
            }
        }
    }
}
