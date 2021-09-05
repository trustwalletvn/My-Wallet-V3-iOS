// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct AccountPickerHeaderBuilder: HeaderBuilder {

    private let headerType: AccountPickerHeaderType

    public init(headerType: AccountPickerHeaderType) {
        self.headerType = headerType
    }

    public var defaultHeight: CGFloat {
        switch headerType {
        case .none:
            return 0
        case .default:
            return AccountPickerHeaderModel.defaultHeight
        case .simple:
            return AccountPickerSimpleHeaderModel.defaultHeight
        }
    }

    public func view(fittingWidth width: CGFloat, customHeight: CGFloat?) -> UIView? {
        let height = customHeight ?? defaultHeight
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        switch headerType {
        case .none:
            return nil
        case .default(let model):
            let headerView = AccountPickerHeaderView(frame: frame)
            headerView.model = model
            return headerView
        case .simple(let model):
            let headerView = AccountPickerSimpleHeaderView(frame: frame)
            headerView.model = model
            return headerView
        }
    }
}
