import ComposableArchitecture
import SwiftUI

struct AccountPickerState: Equatable {
    var rows: IdentifiedArrayOf<AccountPickerRow>
    var header: Header?
}

// MARK: Header model

extension AccountPickerState {

    struct HeaderModel: Equatable {
        let title: String
        let subtitle: String
        let image: Image?
        let listTitle: String?

        init(title: String, subtitle: String, image: Image? = nil, listTitle: String? = nil) {
            self.title = title
            self.subtitle = subtitle
            self.image = image
            self.listTitle = listTitle
        }
    }

    enum Header: Equatable {
        case standard(HeaderModel)
        case simple(HeaderModel)
    }
}
