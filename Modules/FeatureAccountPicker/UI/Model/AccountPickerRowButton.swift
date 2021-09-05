// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension AccountPickerRow {

    public struct ButtonModel: Equatable {

        public init(text: String) {
            self.text = text
        }

        var text: String
    }
}
