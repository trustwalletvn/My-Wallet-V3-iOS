// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

public final class MockViewController: UIViewController {

    public struct RecordedInvocations {
        public var dismiss: [(animated: Bool, completion: (() -> Void)?)] = []
        public var presentViewController: [UIViewController] = []
    }

    public private(set) var recordedInvocations = RecordedInvocations()

    override public func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)? = nil
    ) {
        recordedInvocations.presentViewController.append(viewControllerToPresent)
    }

    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        recordedInvocations.dismiss.append((flag, completion))
    }
}
