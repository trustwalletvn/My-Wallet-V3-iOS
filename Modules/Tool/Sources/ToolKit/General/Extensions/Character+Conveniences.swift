// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Character {
    public func inSet(characterSet: CharacterSet) -> Bool {
        CharacterSet(charactersIn: "\(self)").isSubset(of: characterSet)
    }
}
