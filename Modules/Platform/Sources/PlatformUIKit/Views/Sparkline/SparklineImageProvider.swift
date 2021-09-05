// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa
import RxRelay
import RxSwift
import UIKit

/// For more information, see [Wikipedia.](https://en.wikipedia.org/wiki/Sparkline)
/// Per the definition, the `Sparkline` is not intended to be a visual representation
/// with (x,y) coordinates, but rather memorable and succint.
public final class SparklineImageProvider {

    // MARK: - Public Properties

    /// The `Sparkline` image which should be inserted into a `UIImageView`.
    public var image: Driver<UIImage?> {
        imageRelay.asDriver()
    }

    // MARK: - Private Properties

    private let presenter: SparklineImagePresenter
    private let imageRelay: BehaviorRelay<UIImage?> = BehaviorRelay(value: nil)
    private let disposeBag = DisposeBag()

    public init(presenter: SparklineImagePresenter) {
        self.presenter = presenter

        // TODO: Alex - There should be a placeholder for this image as
        // it is loading.
        self.presenter.image
            .drive(imageRelay)
            .disposed(by: disposeBag)
    }
}
