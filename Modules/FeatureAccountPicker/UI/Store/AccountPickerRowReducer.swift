// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

let accountPickerRowReducer =
    Reducer<AccountPickerRow, AccountPickerRowAction, AccountPickerRowEnvironment> { _, action, _ in
        switch action {
        case .accountPickerRowDidTap(let title):
            print("row tapped: \(title)")
            return .none
        }
    }
