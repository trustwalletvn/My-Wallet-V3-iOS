// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit

public final class EmptyNetworkFeeContentInteractor: ContentLabelViewInteractorAPI {
    public var contentCalculationState: Observable<ValueCalculationState<String>> {
        .just(.calculating)
    }

    public init() {}
}
