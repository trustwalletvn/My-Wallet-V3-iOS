// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class BadgeNumberedTableViewCell: UITableViewCell {

    public var viewModel: BadgeNumberedItemViewModel! {
        didSet {
            itemView.viewModel = viewModel
        }
    }

    private let itemView = BadgeNumberedItemView()

    // MARK: - Lifecycle

    override public init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        selectionStyle = .none
        contentView.addSubview(itemView)
        itemView.layoutToSuperview(.leading, .top, offset: 24.0)
        itemView.layoutToSuperview(.trailing, offset: -24.0)
        itemView.layout(dimension: .height, to: 80, priority: .defaultLow)
        itemView.layout(edge: .bottom, to: .bottom, of: contentView, offset: -24.0)
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        viewModel = nil
    }
}
