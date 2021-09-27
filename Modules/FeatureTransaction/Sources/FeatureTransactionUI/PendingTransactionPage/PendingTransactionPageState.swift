// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

struct PendingTransactionPageState {

    enum Effect {

        /// Dismiss the pending screen.
        case close

        /// Do nothing. This is usually only
        /// present when the screen is pending
        /// as opposed to a success or failure state.
        case none
    }

    let title: LabelContent
    let subtitle: LabelContent
    let compositeViewType: CompositeStatusViewType
    let effect: Effect
    let buttonViewModel: ButtonViewModel?

    static let empty: PendingTransactionPageState = .init(
        title: "",
        subtitle: "",
        compositeViewType: .none,
        buttonViewModel: nil
    )

    init(
        title: String,
        subtitle: String,
        compositeViewType: CompositeStatusViewType,
        effect: Effect = .none,
        buttonViewModel: ButtonViewModel?
    ) {
        self.title = .init(
            text: title,
            font: .main(.semibold, 20.0),
            color: .titleText,
            alignment: .center,
            accessibility: .init(id: "PendingTransactionTitleLabel")
        )

        self.subtitle = .init(
            text: subtitle,
            font: .main(.medium, 14.0),
            color: .descriptionText,
            alignment: .center,
            accessibility: .init(id: "PendingTransactionSubtitleLabel")
        )

        self.compositeViewType = compositeViewType
        self.buttonViewModel = buttonViewModel
        self.effect = effect
    }
}

extension PendingTransactionPageState {
    var buttonViewModelVisibility: Visibility {
        buttonViewModel == nil ? .hidden : .visible
    }
}
