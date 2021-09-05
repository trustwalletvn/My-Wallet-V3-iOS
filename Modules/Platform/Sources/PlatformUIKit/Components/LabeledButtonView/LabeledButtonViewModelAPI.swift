// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa

/// An interaction later for a label view.
public protocol LabeledButtonViewModelAPI: AnyObject {

    /// Associate an element with the content
    associatedtype Element

    /// Enables to bind the element once tapped
    var elementOnTap: Signal<Element> { get }

    /// Accepts taps
    var tapRelay: PublishRelay<Void> { get }

    /// Determines the background color
    var backgroundColor: Color { get }

    /// Determines the content of the button
    var content: Driver<ButtonContent> { get }
}
