// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class NoticeTableViewCell: UITableViewCell {

    // MARK: - Properties

    public var viewModel: NoticeViewModel! {
        didSet {
            noticeView.viewModel = viewModel
        }
    }

    public var topOffset: CGFloat = 16 {
        didSet {
            verticalConstraints.leading.constant = topOffset
        }
    }

    public var bottomOffset: CGFloat = 16 {
        didSet {
            verticalConstraints.trailing.constant = -bottomOffset
        }
    }

    private let noticeView = NoticeView()
    private var verticalConstraints: Axis.Constraints!

    // MARK: - Lifecycle

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(noticeView)
        noticeView.layoutToSuperview(axis: .horizontal, offset: 24)
        verticalConstraints = noticeView.layoutToSuperview(
            axis: .vertical,
            offset: topOffset
        )
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}
