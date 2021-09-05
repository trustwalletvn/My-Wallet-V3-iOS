// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

/// There are `CheckoutScreenContentReducing` classes for `Buy` as well as `Sell`.
/// These classes provide the `ViewModels` as well as the `CellTypes` for the
/// `CheckoutScreenPresenter`.
protocol CheckoutScreenContentReducing {
    /// The title of the checkout screen
    var title: String { get }
    /// The `Cells` on the `CheckoutScreen`
    var cells: [DetailsScreen.CellType] { get }
    /// Continue button that submits the order
    var continueButtonViewModel: ButtonViewModel { get }
    /// Cancel button that cancels the order
    var cancelButtonViewModel: ButtonViewModel? { get }
    /// `Transfer` button that is only used in `Buy`
    var transferDetailsButtonViewModel: ButtonViewModel? { get }
    /// `Setup` function that is only used in `Buy`
    func setupDidSucceed(with data: CheckoutInteractionData)
}
