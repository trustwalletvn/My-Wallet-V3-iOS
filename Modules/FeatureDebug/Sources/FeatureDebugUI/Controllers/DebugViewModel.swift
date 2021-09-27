// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

final class DebugViewModel {

    enum Effects {
        case route(DebugItemType)
        case close
    }

    // MARK: Inputs

    let itemTapped = PublishRelay<DebugItem>()
    let closeButtonTapped = PublishRelay<Void>()

    // MARK: Outputs

    let items: Driver<[DebugItem]>
    let routeTo: Observable<Effects>

    init(itemsProvider: () -> [DebugItem]) {
        items = Driver.just(itemsProvider())

        let selection = itemTapped
            .map(\.type)
            .map(Effects.route)

        let close = closeButtonTapped
            .map { Effects.close }

        routeTo = Observable.merge(
            selection,
            close
        )
    }
}
