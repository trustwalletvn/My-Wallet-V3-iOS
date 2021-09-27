// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxDataSources

enum NetworkFeeSelectionSectionItem: Equatable, IdentifiableType {
    case label(LabelContent)
    case radio(RadioLineItemCellPresenter)
    case button(ButtonViewModel)
    case separator(Int)

    var identity: AnyHashable {
        switch self {
        case .label(let content):
            return content.text
        case .radio(let presenter):
            return presenter.identity
        case .button(let viewModel):
            return viewModel.textRelay.value + viewModel.isEnabledRelay.value.description
        case .separator(let index):
            return "\(index)"
        }
    }

    static func == (lhs: NetworkFeeSelectionSectionItem, rhs: NetworkFeeSelectionSectionItem) -> Bool {
        switch (lhs, rhs) {
        case (.radio(let left), .radio(let right)):
            return left == right
        case (.button(let left), .button(let right)):
            return left.isEnabledRelay.value == right.isEnabledRelay.value
        case (.separator(let left), .separator(let right)):
            return left == right
        case (.label(let left), .label(let right)):
            return left == right
        default:
            return false
        }
    }
}

struct NetworkFeeSelectionSectionModel: SectionModelType {
    typealias Item = NetworkFeeSelectionSectionItem

    var items: [NetworkFeeSelectionSectionItem]

    init(items: [NetworkFeeSelectionSectionItem]) {
        self.items = items
    }

    init(original: NetworkFeeSelectionSectionModel, items: [Item]) {
        self = original
        self.items = items
    }
}

extension NetworkFeeSelectionSectionModel: Equatable {
    static func == (lhs: NetworkFeeSelectionSectionModel, rhs: NetworkFeeSelectionSectionModel) -> Bool {
        lhs.items == rhs.items
    }
}
