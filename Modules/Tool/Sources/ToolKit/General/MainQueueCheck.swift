// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public func ensureIsOnMainQueue() {
    #if INTERNAL_BUILD
    dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
    #else
    ProbabilisticRunner.run(for: .pointZeroOnePercent) {
        dispatchPrecondition(condition: .onQueue(DispatchQueue.main))
    }
    #endif
}
