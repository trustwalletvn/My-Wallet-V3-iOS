// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class BiometryLabelContentInteractor: LabelContentInteracting {

    typealias InteractionState = LabelContent.State.Interaction

    let stateRelay = BehaviorRelay<InteractionState>(value: .loading)
    var state: Observable<InteractionState> {
        stateRelay.asObservable()
    }

    // MARK: - Private Accessors

    init(biometryProviding: BiometryProviding) {
        var title = LocalizationConstants.Settings.enableTouchID
        switch biometryProviding.supportedBiometricsType {
        case .faceID:
            title = LocalizationConstants.Settings.enableFaceID
        case .touchID:
            title = LocalizationConstants.Settings.enableTouchID
        case .none:
            break
        }
        stateRelay.accept(.loaded(next: .init(text: title)))
    }
}
