// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import SafariServices

/// A protocol for Safari services
public protocol WebViewServiceAPI: AnyObject {
    func openSafari(url: String, from parent: ViewControllerAPI)
    func openSafari(url: URL, from parent: ViewControllerAPI)
}

extension WebViewServiceAPI {

    public func openSafari(url: String, from parent: ViewControllerAPI) {
        guard let url = URL(string: url) else { return }
        openSafari(url: url, from: parent)
    }

    public func openSafari(url: URL, from parent: ViewControllerAPI) {
        let viewController = SFSafariViewController(url: url)
        viewController.modalPresentationStyle = .overFullScreen
        parent.present(viewController, animated: true, completion: nil)
    }
}

class WebViewService: WebViewServiceAPI {}
