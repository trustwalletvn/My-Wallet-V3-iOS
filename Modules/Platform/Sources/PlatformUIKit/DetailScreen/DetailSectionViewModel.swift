// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

public struct DetailSectionViewModel {

    public let identifier: String
    public var items: [DetailCellViewModel]

    /// An identifiable value to support RxDataSources
    public var identity: AnyHashable {
        identifier
    }

    public init(identifier: String, items: [DetailCellViewModel]) {
        self.identifier = identifier
        self.items = items
    }
}

extension DetailSectionViewModel: AnimatableSectionModelType {
    public typealias Item = DetailCellViewModel

    public init(original: DetailSectionViewModel, items: [DetailCellViewModel]) {
        self = original
        self.items = items
    }
}
