// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

final class KYCApplicationCompleteController: KYCBaseViewController, ProgressableView {

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = .green
    var startingValue: Float = 1.0

    override class func make(with coordinator: KYCRouter) -> KYCApplicationCompleteController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .applicationComplete
        return controller
    }

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        navigationItem.hidesBackButton = true
    }
}
