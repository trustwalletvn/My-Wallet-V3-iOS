// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

struct PaymentMethodCellModel: Equatable {
    var items: [PaymentMethodCellViewModelItem]
}

extension PaymentMethodCellModel: SectionModelType {
    typealias Item = PaymentMethodCellViewModelItem

    init(original: PaymentMethodCellModel, items: [PaymentMethodCellViewModelItem]) {
        self = original
        self.items = items
    }
}

enum PaymentMethodCellViewModelItem: Equatable {
    case linkedCard(LinkedCardCellPresenter)
    case account(FiatCustodialBalanceViewPresenter)
    case addNew(AddNewPaymentMethodCellModel)
    case linkedBank(LinkedBankViewModel)
}
