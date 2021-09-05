// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class MultiActionTableViewCell: UITableViewCell {

    public var presenter: MultiActionViewPresenting! {
        didSet {
            multiActionView.presenter = presenter
        }
    }

    @IBOutlet private var multiActionView: MultiActionView!

    // MARK: - Lifecycle

    override public func awakeFromNib() {
        super.awakeFromNib()
    }

    override public func prepareForReuse() {
        super.prepareForReuse()
        presenter = nil
    }
}
