// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

/// Presenters should subclass `Presenter`
open class RibBridgePresenter: Presentable {

    private let interactable: Interactable

    public init(interactable: Interactable) {
        self.interactable = interactable
    }

    open func viewDidLoad() {
        // No-Op
    }

    open func viewWillAppear() {
        interactable.activate()
    }

    open func viewDidDisappear() {
        interactable.deactivate()
    }
}
