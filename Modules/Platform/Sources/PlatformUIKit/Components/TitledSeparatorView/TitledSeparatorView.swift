// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class TitledSeparatorView: UIView {

    // MARK: - Injected

    public var viewModel: TitledSeparatorViewModel! {
        didSet {
            guard let viewModel = viewModel else { return }
            accessibility = viewModel.accessibility
            titleLabel.content = viewModel.titleLabelContent
            separatorView.backgroundColor = viewModel.separatorColor
        }
    }

    // MARK: - UI Properties

    private let titleLabel = UILabel()
    private let separatorView = UIView()

    public init() {
        super.init(frame: UIScreen.main.bounds)

        addSubview(titleLabel)
        addSubview(separatorView)

        titleLabel.layoutToSuperview(.top, .bottom, .leading)
        titleLabel.maximizeResistanceAndHuggingPriorities()

        separatorView.layout(edge: .leading, to: .trailing, of: titleLabel, offset: 8)
        separatorView.layoutToSuperview(.centerY, .trailing)
        separatorView.layout(dimension: .height, to: 1)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
