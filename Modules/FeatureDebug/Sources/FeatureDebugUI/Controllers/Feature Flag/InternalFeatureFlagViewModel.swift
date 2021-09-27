// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

struct InternalFeatureItem: Equatable {
    let type: InternalFeature
    let enabled: Bool

    var title: String {
        type.displayTitle
    }
}

enum InternalFeatureAction {
    case load([InternalFeatureItem])
    case selected(InternalFeatureItem)
}

final class InternalFeatureFlagViewModel {

    let action = PublishRelay<InternalFeatureAction>()

    let items: Driver<[InternalFeatureItem]>

    init(internalFeatureFlagService: InternalFeatureFlagServiceAPI = resolve()) {

        let initialItems = InternalFeature.allCases.map { featureType -> InternalFeatureItem in
            InternalFeatureItem(type: featureType, enabled: internalFeatureFlagService.isEnabled(featureType))
        }

        items = action
            .startWith(.load(initialItems))
            .scan(into: [InternalFeatureItem](), accumulator: { current, action in
                switch action {
                case .load(let items):
                    current = items
                case .selected(let item):
                    guard let index = current.firstIndex(of: item) else { return }
                    if item.enabled {
                        internalFeatureFlagService.disable(item.type)
                    } else {
                        internalFeatureFlagService.enable(item.type)
                    }
                    current[index] = InternalFeatureItem(type: item.type, enabled: !item.enabled)
                }
            })
            .asDriver(onErrorJustReturn: [])
    }
}
