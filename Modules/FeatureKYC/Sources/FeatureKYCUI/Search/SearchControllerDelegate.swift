// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

protocol SearchSelection {}

protocol SearchControllerDelegate: AnyObject {
    func onStart()
    func onSubmission(_ selection: SearchSelection)
    func onSelection(_ selection: SearchSelection)
    func onSubmission(_ address: UserAddress, completion: @escaping () -> Void)
    func onSearchRequest(_ query: String)
    func onSearchViewCancel()
    func onSearchResigned()
}
