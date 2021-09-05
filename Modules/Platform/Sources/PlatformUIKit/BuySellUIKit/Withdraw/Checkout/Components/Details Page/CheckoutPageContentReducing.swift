// Copyright © Blockchain Luxembourg S.A. All rights reserved.

protocol CheckoutPageContentReducing {
    /// The title of the checkout screen
    var title: String { get }
    /// The `Cells` on the `CheckoutPage`
    var cells: [DetailsScreen.CellType] { get }
    var continueButtonViewModel: ButtonViewModel { get }
    var cancelButtonViewModel: ButtonViewModel { get }
}
