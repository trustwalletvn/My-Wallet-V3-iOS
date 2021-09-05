// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol LoadingViewProtocol {
    func animate(from oldState: LoadingViewPresenter.State, text: String?)
    func fadeOut()

    var viewRepresentation: UIView { get }
}

extension LoadingViewProtocol where Self: UIView {
    var viewRepresentation: UIView {
        self
    }
}
