// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public final class MultiActionView: UIView {

    // MARK: - Injected

    public var presenter: MultiActionViewPresenting! {
        didSet {
            disposeBag = DisposeBag()
            guard let presenter = presenter else {
                return
            }
            segmentedView.viewModel = presenter.segmentedViewModel
        }
    }

    // MARK: - Private IBOutlets

    @IBOutlet private var segmentedView: SegmentedView!

    // MARK: - Private Properties

    private var disposeBag = DisposeBag()

    // MARK: - Init

    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        fromNib(in: .module)
    }
}
