// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import SwiftUI

public struct AccountPickerRow: Equatable, Identifiable {

    public enum Kind: Equatable {
        case button(ButtonModel)
        case linkedBankAccount(LinkedBankAccountModel)
        case accountGroup(AccountGroupModel)
        case singleAccount(SingleAccountModel)
    }

    public init(id: AnyHashable = UUID(), kind: Kind) {
        self.id = id
        self.kind = kind
    }

    public var id: AnyHashable
    public var kind: Kind
}
