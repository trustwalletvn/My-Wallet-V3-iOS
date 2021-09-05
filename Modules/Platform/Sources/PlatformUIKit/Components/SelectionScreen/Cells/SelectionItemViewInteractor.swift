// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

final class SelectionItemViewInteractor {

    let item: SelectionItemViewModel
    let isSelectedRelay = BehaviorRelay(value: false)

    private let service: SelectionServiceAPI
    private let disposeBag = DisposeBag()

    init(item: SelectionItemViewModel, service: SelectionServiceAPI) {
        self.item = item
        self.service = service

        isSelectedRelay
            .filter { $0 }
            .map { _ in item }
            .bindAndCatch(to: service.selectedDataRelay)
            .disposed(by: disposeBag)
    }
}

// MARK: - Equatable

extension SelectionItemViewInteractor: Equatable, Hashable {
    public static func == (lhs: SelectionItemViewInteractor, rhs: SelectionItemViewInteractor) -> Bool {
        lhs.item == rhs.item
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(item)
    }
}
