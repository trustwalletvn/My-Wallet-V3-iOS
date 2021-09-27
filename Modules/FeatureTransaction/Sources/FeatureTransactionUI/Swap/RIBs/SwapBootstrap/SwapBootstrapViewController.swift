// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit
import RIBs
import ToolKit

final class SwapBootstrapViewController: UIViewController, SwapBootstrapPresentable, SwapBootstrapViewControllable {

    private let loadingViewPresenter: LoadingViewPresenting

    init(loadingViewPresenter: LoadingViewPresenting = resolve()) {
        self.loadingViewPresenter = loadingViewPresenter
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) { unimplemented() }

    func showLoading() {
        loadingViewPresenter.show(in: view, with: nil)
    }
}
