// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

struct LinkedBanksSectionModel: Equatable {
    var items: [LinkedBanksSectionItem]
}

extension LinkedBanksSectionModel: SectionModelType {
    typealias Item = LinkedBanksSectionItem

    init(original: LinkedBanksSectionModel, items: [LinkedBanksSectionItem]) {
        self = original
        self.items = items
    }
}

enum LinkedBanksSectionItem: Equatable {
    case linkedBank(BeneficiaryLinkedBankViewModel)
    case addNewBank(AddBankCellModel)
}
