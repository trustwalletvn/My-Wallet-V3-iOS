// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxDataSources

struct PortfolioViewModel: AnimatableSectionModelType {

    // MARK: - Types

    typealias Item = PortfolioCellType
    typealias Identity = String

    // MARK: - Static Properties

    static var empty: PortfolioViewModel { .init(items: []) }

    // MARK: - Properties

    let items: [Item]
    var identity: Identity {
        "PortfolioViewModel"
    }

    // MARK: - Init

    init(original: PortfolioViewModel, items: [Item]) {
        self.items = items
    }

    init(items: [Item]) {
        self.items = items
    }
}
