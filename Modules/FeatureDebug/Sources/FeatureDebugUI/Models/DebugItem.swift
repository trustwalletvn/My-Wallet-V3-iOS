// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

enum DebugItemType: CaseIterable {
    case interalFeatureFlags
}

extension DebugItemType {
    var title: String {
        switch self {
        case .interalFeatureFlags:
            return "Internal Feature Flags"
        }
    }

    static func provideAllItems() -> [DebugItem] {
        DebugItemType.allCases.map(DebugItem.init(type:))
    }
}

struct DebugItem: Equatable {
    let title: String
    let type: DebugItemType

    init(type: DebugItemType) {
        title = type.title
        self.type = type
    }
}
