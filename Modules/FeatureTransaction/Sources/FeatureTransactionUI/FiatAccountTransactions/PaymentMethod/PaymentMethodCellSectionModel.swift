// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxDataSources

struct PaymentMethodCellSectionModel: Equatable {
    var items: [PaymentMethodCellViewModelItem]
}

extension PaymentMethodCellSectionModel: SectionModelType {
    typealias Item = PaymentMethodCellViewModelItem

    init(original: PaymentMethodCellSectionModel, items: [PaymentMethodCellViewModelItem]) {
        self = original
        self.items = items
    }
}

enum PaymentMethodCellViewModelItem: Equatable {
    case suggestedPaymentMethod(ExplainedActionViewModel)
}
