// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

public protocol LineItemCellPresenting: AnyObject {

    var interactor: LineItemCellInteracting { get }

    /// The `LabelContentPresenting` for the title of the `LineItem`
    var titleLabelContentPresenter: LabelContentPresenting { get }

    /// The `LabelContentPresenting` for the description of the `LineItem`
    var descriptionLabelContentPresenter: LabelContentPresenting { get }

    /// Some `LineItems` have an image (e.g. clipboard).
    var image: Driver<UIImage?> { get }

    /// Provides a way to adjust the image width if needed, note the default width is 22px
    var imageWidth: Driver<CGFloat> { get }

    /// Some `LineItems` have a different background color (e.g. clipboard
    /// on selection).
    var backgroundColor: Driver<UIColor> { get }

    /// Accepts tap from a view
    var tapRelay: PublishRelay<Void> { get }
}

public protocol LineItemCellInteracting: AnyObject {

    var title: LabelContentInteracting { get }

    var description: LabelContentInteracting { get }
}
