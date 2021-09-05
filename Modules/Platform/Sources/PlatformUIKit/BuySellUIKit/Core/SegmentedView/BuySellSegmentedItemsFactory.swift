// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

// TODO: Use real screens.
class BuySellSegmentedItemsFactory {

    func createItems() -> [SegmentedViewScreenItem] {
        [
            SegmentedViewScreenItem(title: "Buy", viewController: UIViewController()),
            SegmentedViewScreenItem(title: "Sell", viewController: UIViewController())
        ]
    }
}
