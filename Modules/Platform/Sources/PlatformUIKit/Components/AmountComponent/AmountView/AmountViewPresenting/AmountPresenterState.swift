// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// The `Presenter` state of an `AmountViewable` view.
/// At the time of this writing this includes a `SingleAmountView`
/// and an `AmountTranslationView`.
public enum AmountPresenterState {

    /// Used by `SingleAmountPresenter`
    case showLimitButton(CurrencyLabeledButtonViewModel)

    /// Used by `AmountTranslationPresenter`
    case warning(ButtonViewModel)

    /// Used by `AmountTranslationPresenter`
    case showSecondaryAmountLabel

    /// Used by `AmountTranslationPresenter` and
    /// `SingleAmountPresenter`
    case empty
}
