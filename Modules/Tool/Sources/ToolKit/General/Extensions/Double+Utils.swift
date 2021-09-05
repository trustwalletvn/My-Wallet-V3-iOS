// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Double {
    public func string(with decimalPrecision: Int) -> String {
        String(format: "%.\(decimalPrecision)f", self)
    }
}
