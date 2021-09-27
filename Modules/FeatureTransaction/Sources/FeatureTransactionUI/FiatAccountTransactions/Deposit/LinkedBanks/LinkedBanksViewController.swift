// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import RxSwift
import ToolKit
import UIKit

final class LinkedBanksViewController: UIViewController, LinkedBanksViewControllable {

    // MARK: - Public Properties

    weak var listener: LinkedBanksListener?

    // MARK: - Init

    init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }
}
