// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa

protocol PulseContainerViewProtocol {
    func animate()
    func fadeOut()

    var selection: Signal<Void> { get }
    var viewRepresentation: PassthroughView { get }
}

extension PulseContainerViewProtocol where Self: PassthroughView {
    var viewRepresentation: PassthroughView {
        self as PassthroughView
    }
}
