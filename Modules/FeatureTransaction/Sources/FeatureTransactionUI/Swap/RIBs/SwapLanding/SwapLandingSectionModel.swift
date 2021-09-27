// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxDataSources

struct SwapLandingSectionModel: Equatable {
    var items: [SwapLandingSectionItem]
}

extension SwapLandingSectionModel: SectionModelType {
    typealias Item = SwapLandingSectionItem

    init(original: SwapLandingSectionModel, items: [SwapLandingSectionItem]) {
        self = original
        self.items = items
    }
}

enum SwapLandingSectionItem: Equatable {
    case pair(SwapTrendingPairViewModel)
    case separator(index: Int)
}

extension SwapLandingSectionItem {
    static func == (lhs: SwapLandingSectionItem, rhs: SwapLandingSectionItem) -> Bool {
        switch (lhs, rhs) {
        case (.pair(let left), .pair(let right)):
            return left.sourceAccount.currencyType == right.sourceAccount.currencyType &&
                left.destinationAccount.currencyType == right.destinationAccount.currencyType
        case (.separator(index: let left), .separator(index: let right)):
            return left == right
        default:
            return false
        }
    }
}
