// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public class MockUserDefaults: UserDefaults {

    public convenience init() {
        self.init(suiteName: "MockUserDefaults")!
    }

    override public init?(suiteName suitename: String?) {
        super.init(suiteName: suitename)
        super.removePersistentDomain(forName: suitename!)
    }
}
