// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

extension ObservableType {
    // swiftlint:disable line_length
    public func mapCalculationState<Value, TargetValue>(_ map: @escaping (Value) -> TargetValue) -> Observable<ValueCalculationState<TargetValue>> where Element == ValueCalculationState<Value> {
        self.map { $0.mapValue(map) }
    }
}
