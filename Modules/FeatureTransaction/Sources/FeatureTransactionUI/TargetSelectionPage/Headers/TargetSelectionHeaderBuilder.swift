// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

public struct TargetSelectionHeaderBuilder: HeaderBuilder {

    let headerType: TargetSelectionHeaderType

    public init(headerType: TargetSelectionHeaderType) {
        self.headerType = headerType
    }

    public var defaultHeight: CGFloat {
        switch headerType {
        case .none:
            return 0
        case .titledSection:
            return TitledSectionHeaderModel.defaultHeight
        case .section:
            return SourceTargetSectionHeaderModel.defaultHeight
        }
    }

    public func view(fittingWidth width: CGFloat, customHeight: CGFloat?) -> UIView? {
        let height = customHeight ?? defaultHeight
        let frame = CGRect(x: 0, y: 0, width: width, height: height)
        switch headerType {
        case .none:
            return nil
        case .titledSection(let model):
            let headerView = TitledSectionHeaderView(frame: frame)
            headerView.model = model
            return headerView
        case .section(let model):
            let headerView = SourceTargetSectionHeaderView(frame: frame)
            headerView.model = model
            return headerView
        }
    }
}
