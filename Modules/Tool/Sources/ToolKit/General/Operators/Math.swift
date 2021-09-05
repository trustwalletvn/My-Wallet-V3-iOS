// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

precedencegroup PowerPrecedence { higherThan: MultiplicationPrecedence }
infix operator ^^: PowerPrecedence
public func ^^ (radix: Int, power: Int) -> Int {
    Int(pow(Double(radix), Double(power)))
}
