// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol ViewListener: AnyObject {
    func viewDidLoad()
    func viewWillAppear()
    func viewDidAppear()
    func viewDidDisappear()
}

extension ViewListener {
    public func viewDidLoad() {}
    public func viewWillAppear() {}
    public func viewDidAppear() {}
    public func viewDidDisappear() {}
}
